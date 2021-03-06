module Graphics.UI.SDL.TTF where

import Foreign.C.String
import Foreign.Marshal.Alloc
import Foreign.Marshal.Utils
import Foreign.Storable
import Foreign.Ptr
import Control.Monad
import Data.Int

import qualified Graphics.UI.SDL.TTF.FFI as FFI
import Graphics.UI.SDL.TTF.Types
import Graphics.UI.SDL.Types
import Graphics.UI.SDL.Color
import Graphics.UI.SDL.Raw (mkFinalizedSurface)
import Graphics.UI.SDL.Error (getError)
import Graphics.UI.SDL.General (handleError)

import Prelude hiding (init)


init :: IO ()
init = do
    ret <- FFI.init
    when (ret < 0) $ error . (\s -> "init: " ++ show s) =<< getError

quit :: IO ()
quit = FFI.quit

withInit :: IO a -> IO a
withInit a = do init; ret <- a; quit; return ret

openFont :: String -> Int -> IO TTFFont
openFont file ptsize = withCString file $ \cstr -> do
    FFI.TTFFontPtr ptr <- FFI.openFont cstr (fromIntegral ptsize)
    handleError "openFont" ptr (return . TTFFont . FFI.TTFFontPtr)

openFontIndex :: String -> Int -> Int -> IO TTFFont
openFontIndex file ptsize index = withCString file $ \cstr -> liftM TTFFont $ FFI.openFontIndex cstr (fromIntegral ptsize) (fromIntegral index)

getFontStyle :: TTFFont -> IO TTFStyle
getFontStyle (TTFFont fontPtr) = liftM (toEnum . fromIntegral) $ FFI.getFontStyle fontPtr

setFontStyle :: TTFFont -> TTFStyle -> IO ()
setFontStyle (TTFFont fontPtr) style = FFI.setFontStyle fontPtr (fromIntegral $ fromEnum style)

getFontHinting :: TTFFont -> IO TTFHinting
getFontHinting (TTFFont fontPtr) = liftM (toEnum . fromIntegral) $ FFI.getFontHinting fontPtr

setFontHinting :: TTFFont -> TTFHinting -> IO ()
setFontHinting (TTFFont fontPtr) hinting = FFI.setFontHinting fontPtr (fromIntegral $ fromEnum hinting)

getFontHeight :: TTFFont -> IO Int
getFontHeight (TTFFont fontPtr) = liftM fromIntegral $ FFI.getFontHeight fontPtr

getFontAscent :: TTFFont -> IO Int
getFontAscent (TTFFont fontPtr) = liftM fromIntegral $ FFI.getFontAscent fontPtr

getFontDescent :: TTFFont -> IO Int
getFontDescent (TTFFont fontPtr) = liftM fromIntegral $ FFI.getFontDescent fontPtr

getFontKerning :: TTFFont -> IO Int
getFontKerning (TTFFont fontPtr) = liftM fromIntegral $ FFI.getFontKerning fontPtr

setFontKerning :: TTFFont -> Int -> IO ()
setFontKerning (TTFFont fontPtr) i = FFI.setFontKerning fontPtr (fromIntegral i)

fontFaces :: TTFFont -> IO Int64
fontFaces (TTFFont fontPtr) = liftM fromIntegral $ FFI.fontFaces fontPtr

fontFaceIsFixedWidth :: TTFFont -> IO Bool
fontFaceIsFixedWidth (TTFFont fontPtr) = liftM (== 0) $ FFI.fontFaceIsFixedWidth fontPtr

fontFaceFamilyName :: TTFFont -> IO String
fontFaceFamilyName (TTFFont fontPtr) = FFI.fontFaceFamilyName fontPtr >>= peekCString

fontFaceStyleName :: TTFFont -> IO String
fontFaceStyleName (TTFFont fontPtr) = FFI.fontFaceStyleName fontPtr >>= peekCString

peekInts fn (TTFFont fontPtr) text = do
    alloca $ \wPtr ->
      alloca $ \hPtr -> do
        -- TODO: handle errors
        void $ withCString text $ \cstr -> fn fontPtr cstr wPtr hPtr
        w <- peek wPtr
        h <- peek hPtr
        return (fromIntegral w, fromIntegral h)

sizeText :: TTFFont -> String -> IO (Int, Int)
sizeText = peekInts FFI.sizeText

sizeUTF8 :: TTFFont -> String -> IO (Int, Int)
sizeUTF8 = peekInts FFI.sizeUTF8

sizeUNICODE :: TTFFont -> String -> IO (Int, Int)
sizeUNICODE = peekInts FFI.sizeUNICODE

renderTextSolid :: TTFFont -> String -> Color -> IO Surface
renderTextSolid (TTFFont fontPtr) text fg = withCString text $ \cstr -> do
    with fg $ \colorPtr -> do
      ptr <- FFI.renderTextSolid fontPtr cstr colorPtr
      handleError "renderTextSolid" ptr mkFinalizedSurface

renderTextShaded :: TTFFont -> String -> Color -> Color -> IO Surface
renderTextShaded (TTFFont fontPtr) text fg bg = withCString text $ \cstr ->
    with fg $ \fgColorPtr ->
      with bg $ \bgColorPtr -> do
        ptr <- FFI.renderTextShaded fontPtr cstr fgColorPtr bgColorPtr
        handleError "renderTextShaded" ptr mkFinalizedSurface

renderTextBlended :: TTFFont -> String -> Color -> IO Surface
renderTextBlended (TTFFont fontPtr) text color = withCString text $ \cstr ->
    with color $ \colorPtr -> do
      ptr <- FFI.renderTextBlended fontPtr cstr colorPtr
      handleError "renderTextBlended" ptr mkFinalizedSurface

renderUTF8Solid :: TTFFont -> String -> Color -> IO Surface
renderUTF8Solid (TTFFont fontPtr) text fg = withCString text $ \cstr -> do
    with fg $ \colorPtr -> do
      ptr <- FFI.renderUTF8Solid fontPtr cstr colorPtr
      handleError "renderUTF8Solid" ptr mkFinalizedSurface

renderUTF8Shaded :: TTFFont -> String -> Color -> Color -> IO Surface
renderUTF8Shaded (TTFFont fontPtr) text fg bg = withCString text $ \cstr ->
    with fg $ \fgColorPtr ->
      with bg $ \bgColorPtr -> do
        ptr <- FFI.renderUTF8Shaded fontPtr cstr fgColorPtr bgColorPtr
        handleError "renderUTF8Shaded" ptr mkFinalizedSurface

renderUTF8Blended :: TTFFont -> String -> Color -> IO Surface
renderUTF8Blended (TTFFont fontPtr) text color = withCString text $ \cstr ->
    with color $ \colorPtr -> do
      ptr <- FFI.renderUTF8Blended fontPtr cstr colorPtr
      handleError "renderUTF8Blended" ptr mkFinalizedSurface
