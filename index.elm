import Input as I
import open Generator
import open Generator.Standard
import open Shuffle
import open Data.List
import open Core
import open Time
import Window

debug : Bool
debug = False

-- Model
{- Discussion of timestamp at start here: https://github.com/evancz/Elm/pull/416
referencing this example: https://github.com/jvoigtlaender/labyrinth-elm/blob/018bbb5071d51414436e23ef0d0870bfd6396dbc/labyrinth.elm#L138-#L143
-}
timeStampAtStart : Signal Time
timeStampAtStart = fst <~ (timestamp (constant ()))

type Model = { init: Bool, state: [(Int, Bool)], generator: Generator Standard }

-- the initial state of the model
initialState : Model
initialState = { init=False, state=[], generator=generator 0}

-- all combinations of people and moods
allMoods : [(Int, Bool)]
allMoods = concatMap (\i -> [(i, False), (i, True)]) [0..15]

-- all sad moods
allSad : [(Int, Bool)]
allSad = map (\i -> (i, False)) [0..15]

-- Update
-- changes the mood at index n
change n moods =
  let
    switcher (i, m) = if (i == n) then (i, not m) else (i, m)
  in
    map (switcher) moods

-- selects the face at position n, if correct, the faces shuffle and a different happy face is set
select : Int -> Model -> Model
select n model =
  case (lookup n model.state) of
    Nothing -> model
    (Just False) -> model
    (Just True) -> let
                     (state', generator') = shuffle allSad model.generator
                     (val, generator'') = int32Range (0, 15) generator'
                     state'' = change val state'
                   in
                     { model | state <- state''
                             , generator <- generator'' }

-- represents a step in changing the model due to a signal
step : (FaceSelection, Time) -> Model -> Model
step (mSelection, tStart) model = 
  let
    -- initialize the model if empty
    model' = case (model.init) of
               True -> case (mSelection) of
                         Nothing -> model -- SMELL: the regular time signal will route through this branch. Ideally it would indicate an error => error "No selection supplied"
                         (Just selection) -> select selection model
               False -> let
                          m = { init=True, state=(change 0 allSad), generator=(generator (round tStart)) }
                        in
                          select 0 m
  in
    model'

-- Display

-- the dimensions of the faces
size : Int
size = 150

-- creates an image from a url (partially applied)
img : String -> Element
img = fittedImage size size

-- creates an image url from the index and mood
imgUrl : Int -> Bool -> String
imgUrl i happy = 
  let
    name = if happy then "happy" else "sad"
  in
    ("img/" ++ (show i) ++ "_" ++ name ++ ".png")

-- creates a face button
face : (Int, Bool) -> Element
face (i, happy) = 
  let
    e = img (imgUrl i happy)
  in
    faceButton.button (Just i) e

-- creates all the face button elements from the provided mood state
faces : [(Int, Bool)] -> [Element]
faces moods = map (face) moods

-- creates a n-element wide table
grid : Int -> [Element] -> Element
grid n elems =
  let
    ess = chunk n elems
    acrosses = map (\es -> flow right es) ess
    downs = flow down acrosses
  in
    downs

-- renders the model into elements for display
-- includes an imageCache so that the browser downloads all images, to ensure there is not a delay when a new happy face appears
render : Model -> Element
render model = 
  let
    g = grid 4 (faces model.state)
    allImageCache = map (\(i,h) -> fittedImage 0 0 (imgUrl i h)) allMoods
    elements = allImageCache ++ [g]
  in
    if (not debug) 
    then flow down elements
    else flow down (elements ++ [asText model.state])

-- provides the event for all faceButtons to group their events and tie their id to the event
type FaceSelection = Maybe Int
faceButton : { events : Signal FaceSelection
             , button : Maybe Int -> Element -> Element }
faceButton = I.buttons Nothing

signalAtStart : Signal Time
signalAtStart = fps 1

-- represents the input to the system
input : Signal (FaceSelection, Time)
input = lift2 (,) faceButton.events signalAtStart

-- the main application entry point
main : Signal Element
main = lift render (foldp step initialState input)
