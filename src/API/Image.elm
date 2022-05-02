module API.Image exposing
    ( Image, ImageId
    , get
    )

{-|

@docs Image, ImageId
@docs get

-}

import Http
import Http.Extra as Http


type alias Image =
    { id : ImageId
    , content : String
    }


type alias ImageId =
    String


get : ImageId -> (Result Http.Error Image -> msg) -> Cmd msg
get imageId toMsg =
    if imageId == "400/300" then
        Http.mockFailNetworkError 4000 toMsg

    else
        Http.mockSuccess 1200
            { id = imageId
            , content = "https://www.fillmurray.com/" ++ imageId
            }
            toMsg
