module Page.Posts exposing (Model, dataRequests, init, view)

import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Extra as Html
import Store exposing (Store)


type alias Model =
    {}


init : Model
init =
    {}


dataRequests : List Store.Action
dataRequests =
    [ Store.GetPosts ]


view : Store -> Model -> Html msg
view store model =
    Html.text "x"
