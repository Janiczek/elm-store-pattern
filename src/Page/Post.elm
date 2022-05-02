module Page.Post exposing (Model, dataRequests, init, view)

import API.Post exposing (Post, PostId)
import API.User exposing (User, UserId)
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Extra as Html
import RemoteData
import RemoteData.Extra as RemoteData
import Store exposing (Store)
import UI


type alias Model =
    {}


init : Model
init =
    {}


dataRequests : Store -> PostId -> List Store.Action
dataRequests store postId =
    [ Store.GetPosts
    , Store.GetUsers
    ]


view : Store -> PostId -> Model -> Html msg
view store postId model =
    let
        title : String
        title =
            RemoteData.get postId store.posts
                |> RemoteData.map .title
                |> RemoteData.withDefault ("#" ++ postId)
                |> (\s -> "Post " ++ s)
    in
    Html.div
        []
        [ Html.h1
            [ Attrs.class UI.h1 ]
            [ Html.text title ]
        , RemoteData.view title (RemoteData.get postId store.posts) <|
            \post ->
                RemoteData.view "Author" (RemoteData.get post.authorId store.users) <|
                    \user -> postView post user
        ]


postView : Post -> User -> Html msg
postView post user =
    Html.debug ( post, user )
