module Store exposing
    ( Store, init
    , Action(..), runAction, runActions
    , Msg, update
    )

{-|

@docs Store, init
@docs Action, runAction, runActions
@docs Msg, update

-}

import API.Image exposing (Image, ImageId)
import API.Post exposing (Post, PostId)
import API.User exposing (User, UserId)
import Cmd.Extra as Cmd
import Dict exposing (Dict)
import Http
import RemoteData exposing (RemoteData(..), WebData)


type alias Store =
    { -- we're loading all posts at once
      -- GET /api/posts
      posts : WebData (Dict PostId Post)
    , -- we're lazy-loading users as needed
      -- GET /api/users/<ID>
      users : Dict UserId (WebData User)
    , -- images: lazy-loaded per user, but all at once
      -- GET /api/users/<ID>/images
      imagesForUser : Dict UserId (WebData (Dict ImageId Image))
    }


{-| As in, Request
-}
type Action
    = GetPosts
    | GetUser UserId
    | GetImagesForUser UserId
    | CreateImage UserId Image


{-| As in, Response
-}
type Msg
    = HttpError Action Http.Error -- !
    | GotPosts (List Post)
    | GotUser UserId User
    | GotImagesForUser UserId (List Image)
    | CreatedImage UserId Image


init : Store
init =
    { posts = NotAsked
    , users = Dict.empty
    , imagesForUser = Dict.empty
    }


runAction : Action -> Store -> ( Store, Cmd Msg )
runAction action store =
    case action of
        GetPosts ->
            if shouldSendRequest store.posts then
                ( { store | posts = Loading }
                , send action API.Post.getAll GotPosts
                )

            else
                ( store, Cmd.none )

        GetUser userId ->
            Debug.todo "Store.runAction getUser"

        GetImagesForUser userId ->
            Debug.todo "Store.runAction getImagesForUser"

        CreateImage userId image ->
            Debug.todo "Store.runAction createImage"


runActions : List Action -> Store -> ( Store, Cmd Msg )
runActions actions store =
    List.foldl
        (\action ( accStore, cmd ) ->
            ( accStore, cmd )
                |> Cmd.andThen (runAction action)
        )
        ( store, Cmd.none )
        actions


shouldSendRequest : WebData a -> Bool
shouldSendRequest webdata =
    case webdata of
        NotAsked ->
            True

        Loading ->
            False

        Failure _ ->
            True

        Success _ ->
            False


send : Action -> ((Result Http.Error a -> Msg) -> Cmd Msg) -> (a -> Msg) -> Cmd Msg
send action toCmd toSuccessMsg =
    toCmd
        (\result ->
            case result of
                Err err ->
                    HttpError action err

                Ok success ->
                    toSuccessMsg success
        )


update : Msg -> Store -> ( Store, Cmd Msg )
update msg store =
    case msg of
        GotPosts posts ->
            ( { store | posts = Success (dictByIds posts) }
            , Cmd.none
            )

        GotUser userId user ->
            Debug.todo "Store.update gotUser"

        GotImagesForUser userId images ->
            Debug.todo "Store.update gotImages"

        CreatedImage userId image ->
            Debug.todo "Store.update created image"

        HttpError action error ->
            Debug.todo "Store.update http error"


dictByIds : List { a | id : String } -> Dict String { a | id : String }
dictByIds list =
    list
        |> List.map (\item -> ( item.id, item ))
        |> Dict.fromList
