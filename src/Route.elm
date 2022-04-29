module Route exposing (Route(..), fromUrl, toString)

import API.Post exposing (PostId)
import API.User exposing (UserId)
import Url exposing (Url)
import Url.Builder
import Url.Parser exposing ((</>), Parser)


type Route
    = PostsList
    | PostDetail PostId
    | UserDetail UserId
    | UserImages UserId
    | NotFound


toString : Route -> String
toString route =
    let
        segments =
            case route of
                PostsList ->
                    [ "posts" ]

                PostDetail postId ->
                    [ "posts", postId ]

                UserDetail userId ->
                    [ "users", userId ]

                UserImages userId ->
                    [ "users", userId, "images" ]

                NotFound ->
                    [ "not-found" ]
    in
    Url.Builder.absolute segments []


fromUrl : Url -> Route
fromUrl url =
    Url.Parser.parse parser url
        |> Maybe.withDefault NotFound


parser : Parser (Route -> Route) Route
parser =
    Url.Parser.oneOf
        [ Url.Parser.map PostsList Url.Parser.top
        , Url.Parser.map PostsList <| Url.Parser.s "posts"
        , Url.Parser.map PostDetail <| Url.Parser.s "posts" </> Url.Parser.string
        , Url.Parser.map UserDetail <| Url.Parser.s "users" </> Url.Parser.string
        , Url.Parser.map UserImages <| Url.Parser.s "users" </> Url.Parser.string </> Url.Parser.s "images"
        , Url.Parser.map NotFound <| Url.Parser.s "not-found"
        ]
