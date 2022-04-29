module Main exposing (main)

import Browser
import Browser.Navigation
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Extra as Html
import Page.Posts
import Route exposing (Route(..))
import Store exposing (Store)
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

        ( store, storeCmd ) =
            Store.init
                |> Store.runActions (dataRequests route)
    in
    ( { store = store
      , route = route
      , navKey = navKey
      , postsPage = Page.Posts.init
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


dataRequests : Route -> List Store.Action
dataRequests route =
    case route of
        PostsRoute ->
            Page.Posts.dataRequests

        _ ->
            Debug.todo "Main.dataRequests"


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Browser.Document Msg
view model =
    { title = "Example Store app"
    , body =
        [ Html.div [ Attrs.class "p-4" ]
            [ case model.route of
                PostsRoute ->
                    Page.Posts.view model.store model.postsPage

                _ ->
                    Html.todo <| Debug.toString model.route
            , Html.debug model
            ]
        ]
    }
