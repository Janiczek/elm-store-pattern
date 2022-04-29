module API.User exposing (User, UserId, get)

{-|

@docs User, UserId, get

-}

import Http
import Http.Extra as Http


type alias User =
    { id : UserId
    , name : String
    }


type alias UserId =
    String


get : UserId -> (Result Http.Error User -> msg) -> Cmd msg
get id toMsg =
    Http.mockSuccess
        { id = id
        , name = "Test user " ++ id
        }
        toMsg
