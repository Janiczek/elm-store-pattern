module API.Post exposing
    ( Post, PostId
    , getAll
    , create, PostCreateData
    )

{-|

@docs Post, PostId
@docs getAll
@docs create, PostCreateData

-}

import API.Image exposing (ImageId)
import API.User exposing (UserId)
import Http
import Http.Extra as Http


type alias Post =
    { id : PostId
    , title : String
    , authorId : UserId
    , content : String
    , imageIds : List ImageId
    }


type alias PostId =
    String


getAll : (Result Http.Error (List Post) -> msg) -> Cmd msg
getAll toMsg =
    Http.mockSuccess 1500
        [ Post "1" "First" "42" "Hello" [ "200/300" ]
        , Post "2" "Second" "999" "Foo bar" [ "400/300", "300/300" ]
        , Post "4" "Other" "42" "Some other post" [ "500/300", "600/300" ]
        ]
        toMsg


type alias PostCreateData =
    { title : String
    , authorId : UserId
    , content : String
    }


create : PostCreateData -> (Result Http.Error Post -> msg) -> Cmd msg
create data toMsg =
    if data.title == "B" then
        Http.mockFailBadRequestError 1200 toMsg

    else
        Http.mockSuccess 2500
            { id = String.fromInt (String.length data.title + String.length data.content) -- whatever
            , title = data.title
            , authorId = data.authorId
            , content = data.content
            , imageIds = []
            }
            toMsg
