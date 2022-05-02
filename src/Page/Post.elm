module Page.Post exposing (dataRequests, view)

import API.Image exposing (Image)
import API.Post exposing (Post, PostId)
import API.User exposing (User)
import Html exposing (Html)
import Html.Attributes as Attrs
import RemoteData
import RemoteData.Extra as RemoteData
import Route exposing (Route(..))
import Store exposing (Store)
import UI


dataRequests : Store -> PostId -> List Store.Action
dataRequests store postId =
    let
        staticRequests : List Store.Action
        staticRequests =
            [ Store.GetPosts
            , Store.GetUsers
            ]

        dynamicRequests : List Store.Action
        dynamicRequests =
            RemoteData.get postId store.posts
                |> RemoteData.map .imageIds
                |> Debug.log "reqs"
                |> RemoteData.withDefault []
                |> List.map Store.GetImage
    in
    staticRequests ++ dynamicRequests


view : Store -> PostId -> Html msg
view store postId =
    let
        title : String
        title =
            RemoteData.get postId store.posts
                |> RemoteData.map (.title >> (\s -> "\"" ++ s ++ "\""))
                |> RemoteData.withDefault ("#" ++ postId)
                |> (\s -> "Post: " ++ s)
    in
    Html.div
        []
        [ Html.h1
            [ Attrs.class UI.h1 ]
            [ Html.text title ]
        , RemoteData.view title (RemoteData.get postId store.posts) <|
            \post ->
                RemoteData.view "Author" (RemoteData.get post.authorId store.users) <|
                    \user ->
                        RemoteData.view "Images" (RemoteData.traverse (\imageId -> RemoteData.get_ imageId store.images) post.imageIds) <|
                            \images -> postView post user images
        ]


postView : Post -> User -> List Image -> Html msg
postView post user images =
    Html.div [ Attrs.class "gap-2 flex flex-col" ]
        [ Html.div []
            [ Html.text "Author: "
            , Html.a
                [ Attrs.href (Route.toString (UserRoute user.id))
                , Attrs.class UI.a
                ]
                [ Html.text user.name ]
            ]
        , Html.div [] [ Html.text post.content ]
        , Html.div [] (images |> List.map (\image -> Html.img [ Attrs.src image.content ] []))
        ]
