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

import API.Image exposing (Image, ImageCreateData, ImageId)
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
    | CreateImage ImageCreateData


{-| As in, Response
-}
type Msg
    = HttpError Action Http.Error -- !
    | GotPosts (List Post)
    | GotUsers (List User)
    | GotImage Image
    | CreatedImage Image


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
            if shouldSendRequest (getWebData imageId store.images) then
                ( { store | images = Dict.insert imageId Loading store.images }
                , send action (API.Image.get imageId) GotImage
                )

            else
                ( store, Cmd.none )

        CreateImage imageCreateData ->
            ( store
            , send action (API.Image.create imageCreateData) CreatedImage
            )


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


getWebData : comparable -> Dict comparable (WebData a) -> WebData a
getWebData key dict =
    Dict.get key dict
        |> Maybe.withDefault NotAsked


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

        CreatedImage image ->
            ( { store | images = Dict.insert image.id (Success image) store.images }
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

        CreateImage _ ->
            store


dictByIds : List { a | id : String } -> Dict String { a | id : String }
dictByIds list =
    list
        |> List.map (\item -> ( item.id, item ))
        |> Dict.fromList
