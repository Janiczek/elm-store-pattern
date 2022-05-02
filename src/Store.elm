module Store exposing
    ( Store, init
    , Action(..), runAction
    , Msg(..), update
    )

{-|

@docs Store, init
@docs Action, runAction
@docs Msg, update

-}

import API.Image exposing (Image, ImageId)
import API.Post exposing (Post, PostCreateData, PostId)
import API.User exposing (User, UserId)
import Cmd.Extra as Cmd
import Dict exposing (Dict)
import Http
import RemoteData exposing (RemoteData(..), WebData)
import RemoteData.Extra as RemoteData


type alias Store =
    { -- we're loading all posts at once
      -- GET /api/posts
      posts : WebData (Dict PostId Post)
    , -- we're loading all users at once
      -- GET /api/users/
      users : WebData (Dict UserId User)
    , -- we're lazy loading images as needed
      -- GET /api/images/<ID>
      images : Dict ImageId (WebData Image)
    }


{-| As in, Request
-}
type Action
    = GetPosts
    | GetUsers
    | GetImage ImageId
    | CreatePost PostCreateData


{-| As in, Response
-}
type Msg
    = HttpError Action Http.Error -- !
    | GotPosts (List Post)
    | GotUsers (List User)
    | GotImage Image
    | CreatedPost Action Post


init : Store
init =
    { posts = NotAsked
    , users = NotAsked
    , images = Dict.empty
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

        GetUsers ->
            if shouldSendRequest store.users then
                ( { store | users = Loading }
                , send action API.User.getAll GotUsers
                )

            else
                ( store, Cmd.none )

        GetImage imageId ->
            if shouldSendRequest (RemoteData.get_ imageId store.images) then
                ( { store | images = Dict.insert imageId Loading store.images }
                , send action (API.Image.get imageId) GotImage
                )

            else
                ( store, Cmd.none )

        CreatePost postCreateData ->
            ( store
            , send action (API.Post.create postCreateData) (CreatedPost action)
            )


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

        GotUsers users ->
            ( { store | users = Success (dictByIds users) }
            , Cmd.none
            )

        GotImage image ->
            ( { store | images = Dict.insert image.id (Success image) store.images }
            , Cmd.none
            )

        CreatedPost _ post ->
            ( { store | posts = RemoteData.map (Dict.insert post.id post) store.posts }
            , Cmd.none
            )

        HttpError action error ->
            ( saveFailure action error store
            , Cmd.none
            )


saveFailure : Action -> Http.Error -> Store -> Store
saveFailure action err store =
    case action of
        GetPosts ->
            { store | posts = Failure err }

        GetUsers ->
            { store | users = Failure err }

        GetImage imageId ->
            { store | images = Dict.insert imageId (Failure err) store.images }

        CreatePost _ ->
            store


dictByIds : List { a | id : String } -> Dict String { a | id : String }
dictByIds list =
    list
        |> List.map (\item -> ( item.id, item ))
        |> Dict.fromList
