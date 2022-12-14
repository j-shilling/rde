;;; rde --- Reproducible development environment.
;;;
;;; Copyright © 2022 Andrew Tropin <andrew@trop.in>
;;;
;;; This file is part of rde.
;;;
;;; rde is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; rde is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with rde.  If not, see <http://www.gnu.org/licenses/>.

(define-module (rde packages messaging)
  #:use-module (gnu packages)
  #:use-module (gnu packages messaging)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages documentation)
  #:use-module (gnu packages gperf)
  #:use-module (gnu packages php)
  #:use-module (gnu packages tls)

  #:use-module (guix build-system cmake)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix utils))

(define-public tdlib-latest
  (let ((commit "047246f366d94b55ea7b6b93b3a4baa9a3380154")
        (revision "0"))
    (package
      (inherit tdlib)
      (name "tdlib")
      (version (git-version "1.8.3" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/tdlib/td")
               (commit commit)))
         (sha256
          (base32 "0iy6c6937schr8yd4ni3zc16gcp1ighmf69d5p0b23lrq2b9jq5k"))
         (file-name (git-file-name name version))))
      (arguments
       (substitute-keyword-arguments (package-arguments tdlib)
         ((#:tests? _ #f) #f))))))
