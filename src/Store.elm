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
    , -- we're lazy-loading users as needed
      -- GET /api/users/<ID>
      users : Dict UserId (WebData User)
    , -- images: lazy-loaded per user, but all at once
      -- GET /api/users/<ID>/images
      userImages : Dict UserId (WebData (Dict ImageId Image))
    }


{-| As in, Request
-}
type Action
    = GetPosts
    | GetUser UserId
    | GetUserImages UserId
    | CreateImage ImageCreateData


{-| As in, Response
-}
type Msg
    = HttpError Action Http.Error -- !
    | GotPosts (List Post)
    | GotUser UserId User
    | GotUserImages UserId (List Image)
    | CreatedImage Image


init : Store
init =
    { posts = NotAsked
    , users = Dict.empty
    , userImages = Dict.empty
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
            if shouldSendRequest (getWebData userId store.users) then
                ( { store | users = Dict.insert userId Loading store.users }
                , send action (API.User.get userId) (GotUser userId)
                )

            else
                ( store, Cmd.none )

        GetUserImages userId ->
            if shouldSendRequest (getWebData userId store.userImages) then
                ( { store | userImages = Dict.insert userId Loading store.userImages }
                , send action (API.Image.getAllForUser userId) (GotUserImages userId)
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

        GotUser userId user ->
            ( { store | users = Dict.insert userId (Success user) store.users }
            , Cmd.none
            )

        GotUserImages userId images ->
            ( { store | userImages = Dict.insert userId (Success (dictByIds images)) store.userImages }
            , Cmd.none
            )

        CreatedImage image ->
            -- We arbitrarily decide to reload user's images after getting the success.
            store
                |> runAction (GetUserImages image.owner)

        HttpError action error ->
            Debug.todo "Store.update http error"


dictByIds : List { a | id : String } -> Dict String { a | id : String }
dictByIds list =
    list
        |> List.map (\item -> ( item.id, item ))
        |> Dict.fromList
