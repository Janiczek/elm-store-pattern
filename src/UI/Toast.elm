module UI.Toast exposing (failure, sent, success)

import Html exposing (Html)
import Html.Attributes as Attrs
import Svg
import Svg.Attributes as SvgAttrs


toast : Html msg -> String -> Html msg
toast icon message =
    Html.div
        [ Attrs.class "flex items-center w-full max-w-xs p-4 mb-4 text-gray-500 bg-white rounded-lg shadow dark:text-gray-400 dark:bg-gray-800"
        , Attrs.attribute "role" "alert"
        ]
        [ icon
        , Html.div
            [ Attrs.class "ml-3 text-sm font-normal" ]
            [ Html.text message ]
        , Html.button
            [ Attrs.type_ "button"
            , Attrs.class "ml-auto -mx-1.5 -my-1.5 bg-white text-gray-400 hover:text-gray-900 rounded-lg focus:ring-2 focus:ring-gray-300 p-1.5 hover:bg-gray-100 inline-flex h-8 w-8 dark:text-gray-500 dark:hover:text-white dark:bg-gray-800 dark:hover:bg-gray-700"
            , Attrs.attribute "aria-label" "Close"
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


success : String -> Html msg
success message =
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
    toast successIcon message


failure : String -> Html msg
failure message =
    let
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
    toast failureIcon message


sent : String -> Html msg
sent message =
    let
        sentIcon : Html msg
        sentIcon =
            Html.div
                [ Attrs.class "inline-flex items-center justify-center flex-shrink-0 w-8 h-8 text-blue-500 bg-blue-100 rounded-lg dark:bg-blue-800 dark:text-blue-200" ]
                [ Svg.svg
                    [ SvgAttrs.class "w-5 h-5 text-blue-600 dark:text-blue-500"
                    , SvgAttrs.viewBox "0 0 256 256"
                    ]
                    [ Svg.path
                        [ SvgAttrs.fill "currentColor"
                        , SvgAttrs.d "M511.6 36.86l-64 415.1c-1.5 9.734-7.375 18.22-15.97 23.05c-4.844 2.719-10.27 4.097-15.68 4.097c-4.188 0-8.319-.8154-12.29-2.472l-122.6-51.1l-50.86 76.29C226.3 508.5 219.8 512 212.8 512C201.3 512 192 502.7 192 491.2v-96.18c0-7.115 2.372-14.03 6.742-19.64L416 96l-293.7 264.3L19.69 317.5C8.438 312.8 .8125 302.2 .0625 289.1s5.469-23.72 16.06-29.77l448-255.1c10.69-6.109 23.88-5.547 34 1.406S513.5 24.72 511.6 36.86z"
                        ]
                        []
                    ]
                ]
    in
    toast sentIcon message
