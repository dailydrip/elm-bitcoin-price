module Hello exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (..)
import Json.Decode exposing (Decoder, at, list, string, succeed)
import Http
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Button as Button


type alias Model =
    { currentPrice : Maybe String
    }


init : ( Model, Cmd Msg )
init =
    update GetBitcoinPrice { currentPrice = Nothing }


type Msg
    = GotBitcoinPrice (Result Http.Error String)
    | GetBitcoinPrice
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

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
                    ( { model | currentPrice = Just price }, Cmd.none )


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
        , subscriptions = always Sub.none
        }


mainContent : Model -> Html Msg
mainContent model =
    div []
        [ p [] [ h1 [] [ text "Bitcoin Price" ], h5 [] [ text "It costs right\n        now:" ] ]
        , p [ class "alert alert-success" ]
            [ h4 []
                [ text
                    (Maybe.withDefault
                        "Not yet!"
                        model.currentPrice
                    )
                , text " USD"
                ]
            ]
        , Button.button
            [ Button.outlinePrimary
            , Button.attrs [ onClick GetBitcoinPrice ]
            ]
            [ text "Update it now" ]
        , div [ class "text-right small" ]
            [ a [ href "https://github.com/dailydrip/elm-bitcoin-price" ]
                [ text
                    "Source Code"
                ]
            ]
        ]


view : Model -> Html Msg
view model =
    Grid.container [ class "text-center jumbotron" ]
        -- Responsive fixed width container
        [ CDN.stylesheet -- Inlined Bootstrap CSS for use with reactor
        , mainContent model
        ]
