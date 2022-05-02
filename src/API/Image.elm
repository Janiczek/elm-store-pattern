module API.Image exposing
    ( Image, ImageId
    , get
    , create, ImageCreateData
    )

{-|

@docs Image, ImageId
@docs get
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
    }


type alias ImageId =
    String


get : ImageId -> (Result Http.Error Image -> msg) -> Cmd msg
get imageId toMsg =
    Http.mockSuccess 1200
        { id = imageId
        , width = 640
        , height = 480
        , content = "blob"
        }
        toMsg


type alias ImageCreateData =
    { content : String
    , owner : UserId
    }


create : ImageCreateData -> (Result Http.Error Image -> msg) -> Cmd msg
create data toMsg =
    Http.mockSuccess 2500
        { id = "10"
        , width = 800
        , height = 600
        , content = data.content
        }
        toMsg
