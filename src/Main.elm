module Main exposing (Flags, Model, Msg, main)

import API.Post exposing (PostCreateData)
import Browser
import Browser.Navigation
import Cmd.Extra as Cmd
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attrs
import Page.Post
import Page.Posts
import Page.User
import RemoteData exposing (RemoteData(..), WebData)
import RemoteData.Extra as RemoteData
import Route exposing (Route(..))
import Store exposing (Store)
import UI
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


type alias Model =
    { store : Store
    , route : Route
    , navKey : Browser.Navigation.Key
    }


type Msg
    = StoreMsg Store.Msg
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
    }
        |> sendDataRequests requests


sendDataRequest : Store.Action -> Model -> ( Model, Cmd Msg )
sendDataRequest request model =
    sendDataRequests [ request ] model


sendDataRequests : List Store.Action -> Model -> ( Model, Cmd Msg )
sendDataRequests requests model =
    let
        ( newStore, storeCmd ) =
            model.store
                |> Store.runActions requests
    in
    ( { model | store = newStore }
    , Cmd.map StoreMsg storeCmd
    )


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
            in
            ( { model | store = newStore }
            , Cmd.map StoreMsg storeCmd
            )
                |> Cmd.andThen (sendDataRequests requests)

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
            model
                |> sendDataRequest (Store.CreatePost data)


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
        ]
    }


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
