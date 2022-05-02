module Page.Posts exposing (Config, dataRequests, view)

import API.Post exposing (Post, PostCreateData, PostId)
import API.User exposing (User, UserId)
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Events
import RemoteData.Extra as RemoteData
import Route exposing (Route(..))
import Store exposing (Store)
import UI


dataRequests : List Store.Action
dataRequests =
    [ Store.GetPosts
    , Store.GetUsers
    ]


type alias Config msg =
    { createPost : PostCreateData -> msg
    }


view : Config msg -> Store -> Html msg
view config store =
    Html.div
        []
        [ Html.h1
            [ Attrs.class UI.h1 ]
            [ Html.text "Posts" ]
        , RemoteData.view "Posts" store.posts <|
            \posts ->
                RemoteData.view "Users" store.users <|
                    \users ->
                        postsView config posts users
        ]


postsView : Config msg -> Dict PostId Post -> Dict UserId User -> Html msg
postsView config posts users =
    Html.div
        [ Attrs.class "flex flex-col gap-2" ]
        [ Html.table [ Attrs.class "w-min" ]
            [ Html.thead []
                [ Html.tr []
                    ([ "ID"
                     , "Title"
                     , "Author"
                     , "Images"
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
        , Html.div
            [ Attrs.class "flex flex-row gap-2" ]
            [ Html.button
                [ Events.onClick
                    (config.createPost
                        { title = "A"
                        , authorId = "4"
                        , content = "I am A!"
                        }
                    )
                , Attrs.class UI.blueButton
                ]
                [ Html.text "Create post A" ]
            , Html.button
                [ Events.onClick
                    (config.createPost
                        { title = "B"
                        , authorId = "42"
                        , content = "B side"
                        }
                    )
                , Attrs.class UI.blueButton
                ]
                [ Html.text "Create post B" ]
            , Html.button
                [ Events.onClick
                    (config.createPost
                        { title = "C"
                        , authorId = "999"
                        , content = "C C C C C"
                        }
                    )
                , Attrs.class UI.blueButton
                ]
                [ Html.text "Create post C" ]
            ]
        ]


postRowView : Dict UserId User -> Post -> Html msg
postRowView users post =
    let
        cell : ( String, Maybe Route ) -> Html msg
        cell ( text, maybeRoute ) =
            Html.td
                [ Attrs.class UI.td
                ]
                [ maybeRoute
                    |> Maybe.map
                        (\route ->
                            Html.a
                                [ Attrs.href (Route.toString route)
                                , Attrs.class UI.a
                                ]
                                [ Html.text text ]
                        )
                    |> Maybe.withDefault (Html.text text)
                ]
    in
    Html.tr []
        ([ ( post.id, Just (PostRoute post.id) )
         , ( post.title, Just (PostRoute post.id) )
         , ( Dict.get post.authorId users
                |> Maybe.map .name
                |> Maybe.withDefault ("#" ++ post.authorId)
           , Just (UserRoute post.authorId)
           )
         , ( String.repeat (List.length post.imageIds) "🌆"
           , Nothing
           )
         ]
            |> List.map cell
        )
