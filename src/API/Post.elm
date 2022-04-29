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
        [ Post "1" "First" "42"
        , Post "2" "Second" "999"
        , Post "4" "Other" "42"
        ]
        toMsg
