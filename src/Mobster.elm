module Mobster exposing (..)

import Array
import Maybe
import Array.Extra


type alias MobsterData =
    { mobsters : List String, nextDriver : Int }


empty : MobsterData
empty =
    { mobsters = [], nextDriver = 0 }


add : String -> MobsterData -> MobsterData
add mobster list =
    { list | mobsters = (List.append list.mobsters [ mobster ]) }


type alias DriverNavigator =
    { driver : String
    , navigator : String
    }


nextDriverNavigator : MobsterData -> DriverNavigator
nextDriverNavigator list =
    let
        mobstersAsArray =
            Array.fromList list.mobsters

        maybeDriver =
            Array.get list.nextDriver mobstersAsArray

        driver =
            case maybeDriver of
                Just justDriver ->
                    justDriver

                Nothing ->
                    ""

        maybeNavigator =
            Array.get (nextIndex list.nextDriver list) mobstersAsArray

        navigator =
            case maybeNavigator of
                Just justNavigator ->
                    justNavigator

                Nothing ->
                    driver
    in
        { driver = driver
        , navigator = navigator
        }


nextIndex : Int -> MobsterData -> Int
nextIndex currentIndex mobsterList =
    let
        mobSize =
            List.length mobsterList.mobsters

        index =
            if mobSize == 0 then
                0
            else
                (currentIndex + 1) % mobSize
    in
        index


rotate : MobsterData -> MobsterData
rotate mobsterList =
    { mobsterList | nextDriver = (nextIndex mobsterList.nextDriver mobsterList) }


moveDown : Int -> MobsterData -> MobsterData
moveDown itemIndex list =
    moveUp (itemIndex + 1) list


moveUp : Int -> MobsterData -> MobsterData
moveUp itemIndex list =
    let
        asArray =
            Array.fromList list.mobsters

        maybeItemToMove =
            Array.get itemIndex asArray

        maybeNeighboringItem =
            Array.get (itemIndex - 1) asArray

        updatedMobsters =
            case ( maybeItemToMove, maybeNeighboringItem ) of
                ( Just itemToMove, Just neighboringItem ) ->
                    Array.toList
                        (asArray
                            |> Array.set itemIndex neighboringItem
                            |> Array.set (itemIndex - 1) itemToMove
                        )

                ( _, _ ) ->
                    list.mobsters
    in
        { list | mobsters = updatedMobsters }


remove : Int -> MobsterData -> MobsterData
remove index list =
    let
        asArray =
            (Array.fromList list.mobsters)

        updatedMobsters =
            Array.toList (Array.Extra.removeAt index asArray)

        maxIndex =
            ((List.length updatedMobsters) - 1)

        nextDriverInBounds =
            if index > maxIndex && index > 0 then
                maxIndex
            else
                index
    in
        { list | mobsters = updatedMobsters, nextDriver = nextDriverInBounds }


type Role
    = Driver
    | Navigator


type alias Mobster =
    { name : String, role : Maybe Role, index : Int }


type alias Mobsters =
    List Mobster


mobsterListItemToMobster : DriverNavigator -> Int -> String -> Mobster
mobsterListItemToMobster driverNavigator index mobsterName =
    let
        role =
            if mobsterName == driverNavigator.driver then
                Just Driver
            else if mobsterName == driverNavigator.navigator then
                Just Navigator
            else
                Nothing
    in
        { name = mobsterName, role = role, index = index }


mobsters : MobsterData -> Mobsters
mobsters mobsterList =
    List.indexedMap (mobsterListItemToMobster (nextDriverNavigator mobsterList)) mobsterList.mobsters


setNextDriver : Int -> MobsterData -> MobsterData
setNextDriver newDriver mobsterData =
    { mobsterData | nextDriver = newDriver }