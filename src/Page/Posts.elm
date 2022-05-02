module Page.Posts exposing (Model, dataRequests, init, view)

import API.Post exposing (Post, PostId)
import API.User exposing (User, UserId)
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events
import Html.Extra as Html
import RemoteData
import RemoteData.Extra as RemoteData
import Route exposing (Route(..))
import Store exposing (Store)
import UI


type alias Model =
    {}


init : Model
init =
    {}


dataRequests : List Store.Action
dataRequests =
    [ Store.GetPosts
    , Store.GetUsers
    ]


view : Store -> Model -> Html msg
view store model =
    Html.div
        []
        [ Html.h1
            [ Attrs.class UI.h1 ]
            [ Html.text "Posts" ]
        , RemoteData.view "Posts" store.posts <|
            \posts ->
                RemoteData.view "Users" store.users <|
                    \users ->
                        postsView posts users
        ]


postsView : Dict PostId Post -> Dict UserId User -> Html msg
postsView posts users =
    Html.table []
        [ Html.thead []
            [ Html.tr []
                ([ "ID"
                 , "Title"
                 , "Author"
                 ]
                    |> List.map
                        (\title ->
                            Html.th
                                [ Attrs.class UI.th ]
                                [ Html.text title ]
                        )
                )
            ]
        , Html.tbody []
            (posts
                |> Dict.values
                |> List.map (postRowView users)
            )
        ]


postRowView : Dict UserId User -> Post -> Html msg
postRowView users post =
    let
        cell : ( String, Route ) -> Html msg
        cell ( text, route ) =
            Html.td
                [ Attrs.class UI.td
                ]
                [ Html.a
                    [ Attrs.href (Route.toString route)
                    , Attrs.class "underline text-blue-600"
                    ]
                    [ Html.text text ]
                ]
    in
    Html.tr []
        ([ ( post.id, PostRoute post.id )
         , ( post.title, PostRoute post.id )
         , ( Dict.get post.authorId users
                |> Maybe.map .name
                |> Maybe.withDefault ("#" ++ post.authorId)
           , UserRoute post.authorId
           )
         ]
            |> List.map cell
        )
