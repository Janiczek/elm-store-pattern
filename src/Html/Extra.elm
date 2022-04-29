module Html.Extra exposing (debug, todo)

import DebugToJson
import Html exposing (Html)
import Html.Attributes as Attrs


debug : a -> Html msg
debug value =
    value
        |> Debug.toString
        |> DebugToJson.pp
        |> Html.text
        |> List.singleton
        |> Html.pre [ Attrs.class "p-4 bg-purple-100 border-purple-200 border-2 whitespace-pre-wrap" ]


todo : String -> Html msg
todo message =
    Html.div
        [ Attrs.class "p-4 bg-red-100 border-red-200 border-2" ]
        [ Html.text message ]
