module API.Image exposing
    ( Image, ImageId
    , getAllForUser
    , create, ImageCreateData
    )

{-|

@docs Image, ImageId
@docs getAllForUser
@docs create, ImageCreateData

-}

import API.User exposing (UserId)
import Http
import Http.Extra as Http


type alias Image =
    { id : ImageId
    , width : Int
    , height : Int
    , content : String
    , owner : UserId
    }


type alias ImageId =
    String


getAllForUser : UserId -> (Result Http.Error (List Image) -> msg) -> Cmd msg
getAllForUser _ toMsg =
    Http.mockSuccess
        [ Image "1" 640 480 "blob 1" "42"
        , Image "2" 400 300 "blob 2" "999"
        ]
        toMsg


type alias ImageCreateData =
    { content : String
    , owner : UserId
    }


create : ImageCreateData -> (Result Http.Error Image -> msg) -> Cmd msg
create data toMsg =
    Http.mockSuccess
        { id = "10"
        , width = 640
        , height = 480
        , content = data.content
        , owner = data.owner
        }
        toMsg
