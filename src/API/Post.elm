module API.Post exposing (Post, PostId, getAll)

{-|

@docs Post, PostId, getAll

-}

import API.User exposing (UserId)
import Http
import Http.Extra as Http


type alias Post =
    { id : PostId
    , title : String
    , author : UserId
    }


type alias PostId =
    String


getAll : (Result Http.Error (List Post) -> msg) -> Cmd msg
getAll toMsg =
    Http.mockSuccess
        [ Post "1" "First post" "42"
        , Post "2" "Second post" "999"
        , Post "4" "Some other post" "42"
        ]
        toMsg
