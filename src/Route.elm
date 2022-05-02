module Route exposing (Route(..), fromUrl, toString)

import API.Post exposing (PostId)
import API.User exposing (UserId)
import Url exposing (Url)
import Url.Builder
import Url.Parser exposing ((</>), Parser)


type Route
    = PostsRoute
    | PostRoute PostId
    | UserRoute UserId
    | NotFoundRoute


toString : Route -> String
toString route =
    let
        segments : List String
        segments =
            case route of
                PostsRoute ->
                    [ "posts" ]

                PostRoute postId ->
                    [ "posts", postId ]

                UserRoute userId ->
                    [ "users", userId ]

                NotFoundRoute ->
                    [ "not-found" ]
    in
    Url.Builder.absolute segments []


fromUrl : Url -> Route
fromUrl url =
    Url.Parser.parse parser url
        |> Maybe.withDefault NotFoundRoute


parser : Parser (Route -> Route) Route
parser =
    Url.Parser.oneOf
        [ Url.Parser.map PostsRoute Url.Parser.top
        , Url.Parser.map PostsRoute <| Url.Parser.s "posts"
        , Url.Parser.map PostRoute <| Url.Parser.s "posts" </> Url.Parser.string
        , Url.Parser.map UserRoute <| Url.Parser.s "users" </> Url.Parser.string
        , Url.Parser.map NotFoundRoute <| Url.Parser.s "not-found"
        ]
