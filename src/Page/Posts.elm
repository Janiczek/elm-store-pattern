module Page.Posts exposing (Model, dataRequests, init, view)

import API.Post exposing (Post, PostId)
import Dict exposing (Dict)
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
    Html.div
        []
        [ Html.h1
            [ Attrs.class "font-bold mb-2 border-b border-b-4 border-slate-200" ]
            [ Html.text "Posts" ]
        , store.posts
            |> Html.webDataView "Posts" postsView
        ]


postsView : Dict PostId Post -> Html msg
postsView posts =
    Html.table []
        [ Html.thead []
            ([ "ID"
             , "Title"
             , "Author"
             ]
                |> List.map (\title -> Html.th [ Attrs.class "px-2 bg-slate-100 border-t border-x border-slate-200" ] [ Html.text title ])
            )
        , Html.tbody []
            (posts
                |> Dict.values
                |> List.map postRowView
            )
        ]


postRowView : Post -> Html msg
postRowView post =
    Html.tr []
        ([ .id
         , .title
         , .author
         ]
            |> List.map
                (\getter ->
                    Html.td
                        [ Attrs.class "px-2 border-x border-y border-slate-200" ]
                        [ Html.text (getter post) ]
                )
        )
