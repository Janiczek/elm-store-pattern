module UI.Toast exposing (failure, sent, success)

import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Svg
import Svg.Attributes as SvgAttrs
import UI


htmlToast : Html msg -> { close : msg } -> Html msg -> Html msg
htmlToast icon { close } contents =
    Html.div
        [ Attrs.class "flex items-center w-full max-w-xs p-4 mb-4 text-gray-500 bg-white rounded-lg shadow-md dark:text-gray-400 dark:bg-gray-800"
        , Attrs.attribute "role" "alert"
        ]
        [ icon
        , Html.div
            [ Attrs.class "ml-3" ]
            [ contents ]
        , Html.button
            [ Attrs.type_ "button"
            , Attrs.class "ml-auto -mx-1.5 -my-1.5 bg-white text-gray-400 hover:text-gray-900 rounded-lg focus:ring-2 focus:ring-gray-300 p-1.5 hover:bg-gray-100 inline-flex h-8 w-8 dark:text-gray-500 dark:hover:text-white dark:bg-gray-800 dark:hover:bg-gray-700"
            , Attrs.attribute "aria-label" "Close"
            , Events.onClick close
            ]
            [ Html.span [ Attrs.class "sr-only" ] [ Html.text "Close" ]
            , Svg.svg
                [ SvgAttrs.class "w-5 h-5"
                , SvgAttrs.fill "currentColor"
                , SvgAttrs.viewBox "0 0 20 20"
                ]
                [ Svg.path
                    [ SvgAttrs.fillRule "evenodd"
                    , SvgAttrs.d "M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"
                    , SvgAttrs.clipRule "evenodd"
                    ]
                    []
                ]
            ]
        ]


textToast : Html msg -> { close : msg } -> String -> Html msg
textToast icon c message =
    htmlToast
        icon
        c
        (Html.span
            [ Attrs.class "text-sm font-normal" ]
            [ Html.text message ]
        )


success : { close : msg } -> String -> Html msg
success close message =
    let
        successIcon : Html msg
        successIcon =
            Html.div
                [ Attrs.class "inline-flex items-center justify-center flex-shrink-0 w-8 h-8 text-green-500 bg-green-100 rounded-lg dark:bg-green-800 dark:text-green-200" ]
                [ Svg.svg
                    [ SvgAttrs.class "w-5 h-5"
                    , SvgAttrs.fill "currentColor"
                    , SvgAttrs.viewBox "0 0 20 20"
                    ]
                    [ Svg.path
                        [ SvgAttrs.fillRule "evenodd"
                        , SvgAttrs.d "M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                        , SvgAttrs.clipRule "evenodd"
                        ]
                        []
                    ]
                ]
    in
    textToast successIcon close message


failure : { close : msg, openDetails : msg } -> String -> Html msg
failure c message =
    let
        content : Html msg
        content =
            Html.div
                [ Attrs.class "text-sm font-normal" ]
                [ Html.p [] [ Html.text message ]
                , Html.button
                    [ Events.onClick c.openDetails
                    , Attrs.class UI.redButton
                    ]
                    [ Html.text "Details" ]
                ]

        failureIcon : Html msg
        failureIcon =
            Html.div
                [ Attrs.class "inline-flex items-center justify-center flex-shrink-0 w-8 h-8 text-red-500 bg-red-100 rounded-lg dark:bg-red-800 dark:text-red-200" ]
                [ Svg.svg
                    [ SvgAttrs.class "w-5 h-5"
                    , SvgAttrs.fill "currentColor"
                    , SvgAttrs.viewBox "0 0 20 20"
                    ]
                    [ Svg.path
                        [ SvgAttrs.fillRule "evenodd"
                        , SvgAttrs.d "M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z"
                        , SvgAttrs.clipRule "evenodd"
                        ]
                        []
                    ]
                ]
    in
    htmlToast failureIcon { close = c.close } content


sent : { close : msg } -> String -> Html msg
sent close message =
    let
        sentIcon : Html msg
        sentIcon =
            Html.div
                [ Attrs.class "inline-flex items-center justify-center flex-shrink-0 w-8 h-8 text-blue-500 bg-blue-100 rounded-lg dark:bg-blue-800 dark:text-blue-200" ]
                [ Svg.svg
                    [ SvgAttrs.class "w-5 h-5 text-blue-600 dark:text-blue-500"
                    , SvgAttrs.viewBox "0 0 448 512"
                    ]
                    [ Svg.path
                        [ SvgAttrs.fill "currentColor"
                        , SvgAttrs.d "M438.6 278.6l-160 160C272.4 444.9 264.2 448 256 448s-16.38-3.125-22.62-9.375c-12.5-12.5-12.5-32.75 0-45.25L338.8 288H32C14.33 288 .0016 273.7 .0016 256S14.33 224 32 224h306.8l-105.4-105.4c-12.5-12.5-12.5-32.75 0-45.25s32.75-12.5 45.25 0l160 160C451.1 245.9 451.1 266.1 438.6 278.6z"
                        ]
                        []
                    ]
                ]
    in
    textToast sentIcon close message
