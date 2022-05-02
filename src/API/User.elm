module API.User exposing (User, UserId, getAll)

{-|

@docs User, UserId, getAll

-}

import Http
import Http.Extra as Http


type alias User =
    { id : UserId
    , name : String
    }


type alias UserId =
    String


getAll : (Result Http.Error (List User) -> msg) -> Cmd msg
getAll toMsg =
    Http.mockSuccess 2000
        [ User "999" "Martin"
        , User "42" "Peter"
        , User "4" "Casey"
        ]
        toMsg
