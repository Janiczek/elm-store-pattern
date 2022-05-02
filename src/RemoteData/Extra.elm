module RemoteData.Extra exposing (view)

import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Extra as Html
import RemoteData exposing (RemoteData(..), WebData)


view : String -> WebData a -> (a -> Html msg) -> Html msg
view label data successView =
    case data of
        NotAsked ->
            Html.text ""

        Loading ->
            Html.div [ Attrs.class "inline-flex flex-col shrink items-center gap-2" ]
                [ Html.span [] [ Html.text <| "Loading " ++ label ++ "..." ]
                , Html.spinner
                ]

        Failure err ->
            Html.todo <| "error view for " ++ label ++ ": " ++ Debug.toString err

        Success value ->
            successView value
