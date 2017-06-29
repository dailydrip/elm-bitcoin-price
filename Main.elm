module Hello exposing (..)

import Html exposing (..)
import Json.Decode exposing (Decoder, at, list, string, succeed)
import Http
import Html.Events exposing (onClick)
import Time exposing (every, second)


type alias Model =
    { currentPrice : String
    }


init : ( Model, Cmd Msg )
init =
    update GetBitcoinPrice { currentPrice = "Not yet!" }


type Msg
    = GotBitcoinPrice (Result Http.Error String)
    | GetBitcoinPrice
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        GetBitcoinPrice ->
            ( model, Http.send GotBitcoinPrice getBitcoinPrice )

        GotBitcoinPrice result ->
            case result of
                Err httpError ->
                    let
                        _ =
                            Debug.log "handleBitcoinPriceError" httpError
                    in
                        ( model, Cmd.none )

                Ok price ->
                    ( { model | currentPrice = price }, Cmd.none )


api : String
api =
    "http://api.coindesk.com/v1/bpi/currentprice.json"


getBitcoinPrice : Http.Request String
getBitcoinPrice =
    Http.get api decodeContent


decodeContent : Decoder String
decodeContent =
    at [ "bpi", "USD", "rate" ] string


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every second (always GetBitcoinPrice)


view : Model -> Html Msg
view model =
    div []
        [ p [] [ text "Hello World" ]
        , p [] [ text model.currentPrice ]
        , button [ onClick GetBitcoinPrice ] [ text "get it again" ]
        ]
