module Main exposing (main)

import Browser
import Browser.Navigation
import Html exposing (Html)
import Route exposing (Route)
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
    }


type Msg
    = StoreMsg Store.Msg
    | UrlChanged Url
    | UrlRequested Browser.UrlRequest


init : Flags -> Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init () url navKey =
    ( { store = Store.init
      , route = Route.fromUrl url
      , navKey = navKey
      }
    , Cmd.none
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


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Browser.Document Msg
view model =
    { title = "Example Store app"
    , body =
        [ model
            |> Debug.toString
            |> Html.text
            |> List.singleton
            |> Html.pre []
        ]
    }
