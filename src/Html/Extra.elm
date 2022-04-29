module Html.Extra exposing (debug, todo, webDataView)

import DebugToJson
import Html exposing (Html)
import Html.Attributes as Attrs
import RemoteData exposing (RemoteData(..), WebData)
import Svg
import Svg.Attributes as SvgAttrs


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


webDataView : String -> (a -> Html msg) -> WebData a -> Html msg
webDataView label successView data =
    case data of
        NotAsked ->
            Html.text ""

        Loading ->
            Html.div [ Attrs.class "inline-flex flex-col shrink items-center gap-2" ]
                [ Html.span [] [ Html.text <| "Loading " ++ label ++ "..." ]
                , spinnerView
                ]

        Failure err ->
            todo <| "error view for " ++ label ++ ": " ++ Debug.toString err

        Success value ->
            successView value


spinnerView : Html msg
spinnerView =
    Svg.svg
        [ SvgAttrs.class "animate-spin text-red w-6 h-6"
        , SvgAttrs.fill "none"
        , SvgAttrs.viewBox "0 0 24 24"
        ]
        [ Svg.circle
            [ SvgAttrs.class "opacity-25"
            , SvgAttrs.cx "12"
            , SvgAttrs.cy "12"
            , SvgAttrs.r "10"
            , SvgAttrs.stroke "currentColor"
            , SvgAttrs.strokeWidth "4"
            ]
            []
        , Svg.path
            [ SvgAttrs.class "opacity-75"
            , SvgAttrs.fill "currentColor"
            , SvgAttrs.d "M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
            ]
            []
        ]
