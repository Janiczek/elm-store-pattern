module Page.User exposing (dataRequests, view)

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


dataRequests : Store -> UserId -> List Store.Action
dataRequests store userId =
    [ Store.GetPosts
    , Store.GetUsers
    ]


view : Store -> UserId -> Html msg
view store userId =
    let
        title : String
        title =
            RemoteData.get userId store.users
                |> RemoteData.map .name
                |> RemoteData.withDefault ("#" ++ userId)
                |> (\s -> "User " ++ s)
    in
    Html.div
        []
        [ Html.h1
            [ Attrs.class UI.h1 ]
            [ Html.text title ]
        , RemoteData.view title (RemoteData.get userId store.users) <|
            \user -> userView user
        ]


userView : User -> Html msg
userView user =
    Html.debug user
