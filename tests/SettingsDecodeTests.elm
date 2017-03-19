module SettingsDecodeTests exposing (all)

import Test exposing (..)
import Test.Extra exposing (..)
import Mobster.Data exposing (empty)
import Setup.Settings
import TestHelpers exposing (toMobsters)
import Expect
import Json.Decode as Decode


all : Test
all =
    describe "decoders"
        [ describeDecoder "Settings"
            Setup.Settings.decoder
            [ ( """{
                      "mobsterData": {
                        "mobsters": [],
                        "inactiveMobsters": [],
                        "nextDriver": 0
                      },
                      "timerDuration": 5,
                      "intervalsPerBreak": 6
                    }""", DecodesTo (Setup.Settings.Data 5 6 Mobster.Data.empty) )
            ]
        , describeDecoder "MobsterData"
            Setup.Settings.decoder
            [ ( """{
                      "mobsterData": {
                        "mobsters": ["Uhura", "Sulu"],
                        "inactiveMobsters": ["Kirk", "Spock"],
                        "nextDriver": 0
                      },
                      "timerDuration": 5,
                      "intervalsPerBreak": 6
                    }""", DecodesTo (Setup.Settings.Data 5 6 { empty | mobsters = [ "Uhura", "Sulu" ] |> toMobsters, inactiveMobsters = [ "Kirk", "Spock" ] |> toMobsters }) )
            ]
        , reverseDecoder
        ]


reverseDecoder : Test
reverseDecoder =
    test "decoder is able to parse fields generated in encoder" <|
        \() ->
            Setup.Settings.Data 5 6 { empty | mobsters = [ "Uhura", "Sulu" ] |> toMobsters, inactiveMobsters = [ "Kirk", "Spock" ] |> toMobsters }
                |> Setup.Settings.encoder
                |> Decode.decodeValue Setup.Settings.decoder
                |> Expect.equal
                    (Ok (Setup.Settings.Data 5 6 { empty | mobsters = [ "Uhura", "Sulu" ] |> toMobsters, inactiveMobsters = [ "Kirk", "Spock" ] |> toMobsters }))
