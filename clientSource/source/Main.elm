module Main exposing (Model, Msg, init, subscriptions, update, view)

import Browser
import Html
import Html.Events
import Http
import Json.Decode
import Url


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type Model
    = Model { logInUrl : Maybe Url.Url }


init : () -> ( Model, Cmd Msg )
init () =
    ( Model { logInUrl = Nothing }, Cmd.none )


type Msg
    = RequestLineLogInUrl
    | ResponseLineLogInUrl (Result Http.Error Url.Url)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RequestLineLogInUrl ->
            ( model, Http.get { url = "api/lineLogInUrl", expect = Http.expectJson ResponseLineLogInUrl urlDecoder } )

        ResponseLineLogInUrl result ->
            case result of
                Ok url ->
                    ( Model { logInUrl = Just url }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )


urlDecoder : Json.Decode.Decoder Url.Url
urlDecoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\string ->
                case Url.fromString string of
                    Just url ->
                        Json.Decode.succeed url

                    Nothing ->
                        Json.Decode.fail "URL format error"
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Browser.Document Msg
view model =
    { title = "Document Title"
    , body =
        [ Html.div []
            [ Html.button
                [ Html.Events.onClick RequestLineLogInUrl ]
                [ Html.text "LINE でログイン" ]
            ]
        ]
    }
