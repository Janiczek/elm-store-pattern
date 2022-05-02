module Main exposing (main)

import Browser
import Browser.Navigation
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Extra as Html
import Page.Post
import Page.Posts
import Page.User
import RemoteData exposing (WebData)
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
    , postsPage : Page.Posts.Model
    , postPage : Page.Post.Model
    , userPage : Page.User.Model
    }


type Msg
    = StoreMsg Store.Msg
    | UrlChanged Url
    | UrlRequested Browser.UrlRequest


init : Flags -> Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init () url navKey =
    let
        route =
            Route.fromUrl url

        initStore =
            Store.init

        requests =
            dataRequests initStore route

        ( store, storeCmd ) =
            initStore
                |> Store.runActions requests
    in
    ( { store = store
      , route = route
      , navKey = navKey
      , postsPage = Page.Posts.init
      , postPage = Page.Post.init
      , userPage = Page.User.init
      }
    , Cmd.map StoreMsg storeCmd
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StoreMsg storeMsg ->
            let
                ( newStore, storeCmd ) =
                    Store.update storeMsg model.store
            in
            ( { model | store = newStore }
            , Cmd.map StoreMsg storeCmd
            )

        UrlChanged url ->
            let
                route =
                    Route.fromUrl url
            in
            ( { model | route = route }
            , Cmd.none
            )

        UrlRequested request ->
            case request of
                Browser.Internal url ->
                    ( model, Browser.Navigation.pushUrl model.navKey (Url.toString url) )

                Browser.External urlString ->
                    ( model, Browser.Navigation.load urlString )


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
subscriptions model =
    Sub.none


view : Model -> Browser.Document Msg
view model =
    { title = "Example Store app"
    , body =
        [ Html.div
            [ Attrs.class "p-4 gap-4 flex flex-col" ]
            [ storeLoadView model.store
            , navView model.route
            , case model.route of
                PostsRoute ->
                    Page.Posts.view model.store model.postsPage

                PostRoute postId ->
                    Page.Post.view model.store postId model.postPage

                UserRoute userId ->
                    Page.User.view model.store userId model.userPage

                NotFoundRoute ->
                    Html.text "Page not found"
            ]
        ]
    }


navView : Route -> Html Msg
navView currentRoute =
    let
        routeLabel : Route -> String
        routeLabel route =
            case route of
                PostsRoute ->
                    "All Posts"

                PostRoute id ->
                    "Post #" ++ id

                UserRoute id ->
                    "User #" ++ id

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
                                    [ ( "text-blue-600", True )
                                    , ( "font-bold border-b-2", route == currentRoute )
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

        webdataDict : String -> WebData (Dict comparable a) -> Html msg
        webdataDict label data =
            row label
                (data
                    |> RemoteData.map (\dict_ -> "Dict (" ++ String.fromInt (Dict.size dict_) ++ " items)")
                    |> Debug.toString
                )

        dictWebdata : String -> Dict comparable (WebData a) -> Html msg
        dictWebdata label dict =
            let
                size : Int
                size =
                    Dict.size dict

                count : String -> (WebData a -> Bool) -> Maybe String
                count label_ pred =
                    let
                        n : Int
                        n =
                            dict
                                |> Dict.filter (always pred)
                                |> Dict.size
                    in
                    if n == 0 then
                        Nothing

                    else
                        Just (label_ ++ ": " ++ String.fromInt n ++ "x")

                counts : String
                counts =
                    if size == 0 then
                        ""

                    else
                        [ count "NotAsked" RemoteData.isNotAsked
                        , count "Loading" RemoteData.isLoading
                        , count "Failure" RemoteData.isFailure
                        , count "Success" RemoteData.isSuccess
                        ]
                            |> List.filterMap identity
                            |> String.join ", "
                            |> (\s -> ": " ++ s)
            in
            row label ("Dict (" ++ String.fromInt size ++ " items" ++ counts ++ ")")
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
