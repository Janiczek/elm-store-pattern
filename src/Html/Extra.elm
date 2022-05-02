module Html.Extra exposing (spinner, todo)

import Html exposing (Html)
import Html.Attributes as Attrs
import Svg
import Svg.Attributes as SvgAttrs


todo : String -> Html msg
todo message =
    Html.div
        [ Attrs.class "p-4 bg-red-100 border-red-200 border-2" ]
        [ Html.text message ]


spinner : Html msg
spinner =
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
