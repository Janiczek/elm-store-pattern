module RemoteData.Extra exposing (get, get_, traverse, view)

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Extra as Html
import Http
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
            Html.todo <| "Error view for " ++ label ++ ": " ++ Debug.toString err

        Success value ->
            successView value


get : comparable -> WebData (Dict comparable a) -> WebData a
get key data =
    data
        |> RemoteData.andThen
            (\dict ->
                Dict.get key dict
                    |> RemoteData.fromMaybe
                        (Http.BadBody ("key '" ++ Debug.toString key ++ "' not found"))
            )


get_ : comparable -> Dict comparable (WebData a) -> WebData a
get_ key dict =
    Dict.get key dict
        |> Maybe.withDefault (Failure (Http.BadBody ("key '" ++ Debug.toString key ++ "' not found")))


traverse : (a -> RemoteData x b) -> List a -> RemoteData x (List b)
traverse fn list =
    List.foldl
        (\x acc -> RemoteData.map2 (::) (fn x) acc)
        (Success [])
        list
