module Main exposing (Flags, Model, Msg, main)

import API.Post exposing (PostCreateData)
import Browser
import Browser.Navigation
import Cmd.Extra as Cmd
import Dict exposing (Dict)
import Html exposing (Attribute, Html)
import Html.Attributes as Attrs
import Html.Extra as Html
import Http
import Page.Post
import Page.Posts
import Page.User
import RemoteData exposing (RemoteData(..), WebData)
import RemoteData.Extra as RemoteData
import Route exposing (Route(..))
import Store exposing (Store)
import Toast
import UI
import UI.Toast
import Url exposing (Url)


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        }


type alias Flags =
    ()


type Toast
    = StoreActionSent Store.Action
    | StoreActionSuccess Store.Action
    | StoreActionFailure Store.Action Http.Error


type alias Model =
    { store : Store
    , route : Route
    , navKey : Browser.Navigation.Key
    , notifications : Toast.Tray Toast
    }


type Msg
    = StoreMsg Store.Msg
    | ToastMsg Toast.Msg
    | UrlChanged Url
    | UrlRequested Browser.UrlRequest
    | CreatePost PostCreateData


init : Flags -> Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init () url navKey =
    let
        route : Route
        route =
            Route.fromUrl url

        store : Store
        store =
            Store.init

        requests : List Store.Action
        requests =
            dataRequests store route
    in
    { store = store
    , route = route
    , navKey = navKey
    , notifications = Toast.tray
    }
        |> sendDataRequests requests


sendDataRequest : Store.Action -> Model -> ( Model, Cmd Msg )
sendDataRequest request model =
    let
        ( newStore, storeCmd ) =
            model.store
                |> Store.runAction request
    in
    ( { model | store = newStore }
    , Cmd.map StoreMsg storeCmd
    )


sendDataRequests : List Store.Action -> Model -> ( Model, Cmd Msg )
sendDataRequests requests model =
    List.foldl
        (\request modelAndCmd ->
            modelAndCmd
                |> Cmd.andThen (sendDataRequest request)
        )
        ( model, Cmd.none )
        requests


storeMsgToast : Store.Msg -> Maybe Toast
storeMsgToast storeMsg =
    case storeMsg of
        Store.HttpError action err ->
            Just (StoreActionFailure action err)

        Store.GotPosts _ ->
            Nothing

        Store.GotUsers _ ->
            Nothing

        Store.GotImage _ ->
            Nothing

        Store.CreatedPost action _ ->
            Just (StoreActionSuccess action)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StoreMsg storeMsg ->
            let
                ( newStore, storeCmd ) =
                    Store.update storeMsg model.store

                requests : List Store.Action
                requests =
                    dataRequests newStore model.route

                maybeToast : Maybe Toast
                maybeToast =
                    storeMsgToast storeMsg
            in
            ( { model | store = newStore }
            , Cmd.map StoreMsg storeCmd
            )
                |> Cmd.andThen (sendDataRequests requests)
                |> Cmd.andThenMaybe addToast maybeToast

        ToastMsg toastMsg ->
            let
                ( newNotifications, toastCmd ) =
                    Toast.update toastMsg model.notifications
            in
            ( { model | notifications = newNotifications }
            , Cmd.map ToastMsg toastCmd
            )

        UrlChanged url ->
            let
                newRoute : Route
                newRoute =
                    Route.fromUrl url

                requests : List Store.Action
                requests =
                    dataRequests model.store newRoute
            in
            ( { model | route = newRoute }
            , Cmd.none
            )
                |> Cmd.andThen (sendDataRequests requests)

        UrlRequested request ->
            case request of
                Browser.Internal url ->
                    ( model, Browser.Navigation.pushUrl model.navKey (Url.toString url) )

                Browser.External urlString ->
                    ( model, Browser.Navigation.load urlString )

        CreatePost data ->
            let
                request : Store.Action
                request =
                    Store.CreatePost data
            in
            model
                |> sendDataRequest request
                |> Cmd.andThen (addToast (StoreActionSent request))


addToast : Toast -> Model -> ( Model, Cmd Msg )
addToast toast model =
    let
        ( newNotifications, toastCmd ) =
            Toast.add model.notifications (createToast toast)
    in
    ( { model | notifications = newNotifications }
    , Cmd.map ToastMsg toastCmd
    )


dataRequests : Store -> Route -> List Store.Action
dataRequests store route =
    case route of
        PostsRoute ->
            Page.Posts.dataRequests

        PostRoute postId ->
            Page.Post.dataRequests store postId

        UserRoute userId ->
            Page.User.dataRequests store userId

        NotFoundRoute ->
            []


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


postsPageConfig : Page.Posts.Config Msg
postsPageConfig =
    { createPost = CreatePost
    }


view : Model -> Browser.Document Msg
view model =
    { title = "Example Store app"
    , body =
        [ Html.div
            [ Attrs.class "p-4 gap-4 flex flex-col" ]
            [ storeLoadView model.store
            , navView model.store model.route
            , case model.route of
                PostsRoute ->
                    Page.Posts.view postsPageConfig model.store

                PostRoute postId ->
                    Page.Post.view model.store postId

                UserRoute userId ->
                    Page.User.view model.store userId

                NotFoundRoute ->
                    Html.text "Page not found"
            ]
        , notificationsView model.notifications
        ]
    }


notificationsView : Toast.Tray Toast -> Html Msg
notificationsView tray =
    Html.div
        [ Attrs.class "absolute top-4 right-4" ]
        [ Toast.render toastView tray (Toast.config ToastMsg) ]


createToast toast =
    -- createToast : Toast -> Toast.Toast Toast
    -- the library doesn't expose Toast.Toast so I can't do that :(
    case toast of
        StoreActionSent _ ->
            toast
                |> Toast.expireIn 3000
                |> Toast.withExitTransition 900

        StoreActionSuccess _ ->
            toast
                |> Toast.expireIn 3000
                |> Toast.withExitTransition 900

        StoreActionFailure _ _ ->
            toast
                |> Toast.persistent
                |> Toast.withExitTransition 900


toastView : List (Attribute Msg) -> Toast.Info Toast -> Html Msg
toastView attrs toast =
    (case toast.content of
        StoreActionSent action ->
            case action of
                Store.GetPosts ->
                    Nothing

                Store.GetUsers ->
                    Nothing

                Store.GetImage _ ->
                    Nothing

                Store.CreatePost post ->
                    Just <|
                        UI.Toast.sent <|
                            "Creating post '"
                                ++ post.title
                                ++ "'"

        StoreActionSuccess action ->
            case action of
                Store.GetPosts ->
                    Nothing

                Store.GetUsers ->
                    Nothing

                Store.GetImage _ ->
                    Nothing

                Store.CreatePost post ->
                    Just <|
                        UI.Toast.success <|
                            "Created post '"
                                ++ post.title
                                ++ "'"

        StoreActionFailure action err ->
            case action of
                Store.GetPosts ->
                    Just <| UI.Toast.failure "Failed to get posts"

                Store.GetUsers ->
                    Just <| UI.Toast.failure "Failed to get users"

                Store.GetImage id ->
                    Just <|
                        UI.Toast.failure <|
                            "Failed to get image '"
                                ++ id
                                ++ "'"

                Store.CreatePost post ->
                    Just <|
                        UI.Toast.failure <|
                            "Failed to create post '"
                                ++ post.title
                                ++ "'"
    )
        |> Maybe.map
            (\html ->
                Html.div
                    (Attrs.classList
                        [ ( "transition duration-300 transform-gpu", True )
                        , ( "opacity-0 translate-x-full", toast.phase == Toast.Exit )
                        ]
                        :: attrs
                    )
                    [ html ]
            )
        |> Maybe.withDefault (Html.text "")


navView : Store -> Route -> Html Msg
navView store currentRoute =
    let
        routeLabel : Route -> String
        routeLabel route =
            case route of
                PostsRoute ->
                    "All Posts"

                PostRoute id ->
                    "Post "
                        ++ (RemoteData.get id store.posts
                                |> RemoteData.map (\{ title } -> "\"" ++ title ++ "\"")
                                |> RemoteData.withDefault ("#" ++ id)
                           )

                UserRoute id ->
                    "User "
                        ++ (RemoteData.get id store.users
                                |> RemoteData.map .name
                                |> RemoteData.withDefault ("#" ++ id)
                           )

                NotFoundRoute ->
                    "Not Found"

        stableRoutes : List Route
        stableRoutes =
            [ PostsRoute ]

        allRoutes : List Route
        allRoutes =
            if List.member currentRoute stableRoutes then
                stableRoutes

            else
                stableRoutes ++ [ currentRoute ]
    in
    Html.div [ Attrs.class "flex flex-row gap-2" ]
        (Html.text "Nav: "
            :: (allRoutes
                    |> List.map
                        (\route ->
                            Html.a
                                [ Attrs.href (Route.toString route)
                                , Attrs.classList
                                    [ ( UI.a, True )
                                    , ( "font-bold", route == currentRoute )
                                    ]
                                ]
                                [ Html.text (routeLabel route) ]
                        )
               )
        )


storeLoadView : Store -> Html msg
storeLoadView store =
    let
        row : String -> String -> Html msg
        row label content =
            Html.tr []
                [ Html.td [ Attrs.class UI.td ] [ Html.text label ]
                , Html.td [ Attrs.class UI.td ] [ Html.text content ]
                ]

        webdataSquare : WebData a -> String
        webdataSquare data =
            case data of
                NotAsked ->
                    "⬜️"

                Loading ->
                    "🟨"

                Failure _ ->
                    "🟥"

                Success _ ->
                    "🟩"

        webdataDict : String -> WebData (Dict comparable a) -> Html msg
        webdataDict label data =
            row label
                (webdataSquare data
                    ++ (data
                            |> RemoteData.map (\dict_ -> " Dict (" ++ String.fromInt (Dict.size dict_) ++ " items)")
                            |> RemoteData.withDefault ""
                       )
                )

        dictWebdata : String -> Dict comparable (WebData a) -> Html msg
        dictWebdata label dict =
            let
                contents : String
                contents =
                    if Dict.isEmpty dict then
                        "empty"

                    else
                        dict
                            |> Dict.values
                            |> List.map webdataSquare
                            |> String.concat
            in
            row label ("Dict (" ++ contents ++ ")")
    in
    Html.div
        [ Attrs.class "text-slate-400" ]
        [ Html.h2
            [ Attrs.class "font-bold mb-2 border-b border-b-4 border-slate-200" ]
            [ Html.text "Store status" ]
        , Html.table
            []
            [ webdataDict "posts" store.posts
            , webdataDict "users" store.users
            , dictWebdata "images" store.images
            ]
        ]
