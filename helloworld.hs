{-# LANGUAGE QuasiQuotes, TypeFamilies, OverloadedStrings #-}
{-# LANGUAGE FlexibleInstances, MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleContexts #-}
import Yesod.Core
import Yesod.Dispatch
import Yesod.Content
import Yesod.Handler
import Network.Wai.Handler.Warp (run)

data Subsite = Subsite String

mkYesodSub "Subsite" [] [$parseRoutes|
/ SubRootR GET
|]

getSubRootR :: GHandler Subsite m RepPlain
getSubRootR = do
    Subsite s <- getYesodSub
    tm <- getRouteToMaster
    render <- getUrlRender
    return $ RepPlain $ toContent $ "Hello Sub World: " ++ s ++ ". " ++ render (tm SubRootR)

data HelloWorld = HelloWorld { getSubsite :: String -> Subsite }
mkYesod "HelloWorld" [$parseRoutes|
/ RootR GET
/subsite/#String SubsiteR Subsite getSubsite
|]
instance Yesod HelloWorld where approot _ = ""
getRootR = return $ RepPlain "Hello World"
main = toWaiApp (HelloWorld Subsite) >>= run 3000
