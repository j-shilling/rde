;;; rde --- Reproducible development environment.
;;;
;;; Copyright © 2021, 2022 Andrew Tropin <andrew@trop.in>
;;; Copyright © 2022 Samuel Culpepper <samuel@samuelculpepper.com>
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

(define-module (rde packages emacs-xyz)
  #:use-module (rde packages messaging)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages mail)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages video)
  #:use-module (gnu packages)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix git-download)
  #:use-module (guix build-system emacs)
  #:use-module (guix build-system gnu)
  #:use-module ((guix licenses) #:prefix license:))

(define-public emacs-justify-kp
 (let ((commit "385e6b8b909ae0f570f30101cec3677e21c9e0a0"))
  (package
   (name "emacs-justify-kp")
   (version "20171119")
   (home-page "https://github.com/qzdl/justify-kp")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url home-page)
           (commit commit)))
     (file-name (git-file-name name version))
     (sha256
      (base32 "13fylx4mvw7cgzd2mq060x43b1x7g5vdf16jm49c31f6b3jj1qi0"))))
   (build-system emacs-build-system)
   (inputs (list emacs-dash emacs-s))
   (synopsis "Paragraph justification for emacs using Knuth/Plass algorithm ")
   (description
    "Paragraph justification for emacs using Knuth/Plass algorithm ")
   (license license:gpl3+))))

(define-public emacs-ol-notmuch
  (let* ((commit "1a53d6c707514784cabf33d865b577bf77f45913")
         (revision "0"))
    (package
     (name "emacs-ol-notmuch")
     (version (git-version "2.0.0" revision commit))
     (source
      (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://git.sr.ht/~tarsius/ol-notmuch")
             (commit commit)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "16p7j51z8r047alwn2hkb6944f7ds29ckb97b4k8ia00vwch0d67"))))
     (build-system emacs-build-system)
     (inputs (list emacs-org emacs-compat emacs-notmuch))
     (home-page "https://git.sr.ht/~tarsius/ol-notmuch")
     (synopsis "Links to notmuch messages and searches")
     (description
      "This package implements links to notmuch messages and searches. A search is a query to be performed by notmuch; it is the equivalent to folders in other mail clients. Similarly, mails are referred to by a query, so both a link can refer to several mails.")
     (license license:gpl3+))))


(define-public emacs-cyrillic-dvorak-im
  (package
    (name "emacs-cyrillic-dvorak-im")
    (version "0.1.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/xFA25E/cyrillic-dvorak-im")
             (commit version)))
       (sha256
        (base32 "12adszd4p9i9glx2chasgq68i6cnxcrwbf5c268jjb5dw4q7ci0n"))
       (file-name (git-file-name name version))))
    (build-system emacs-build-system)
    (home-page "https://github.com/xFA25E/cyrillic-dvorak-im")
    (synopsis "Cyrillic input method for dvorak layout")
    (description "Cyrillic input method for dvorak layout.")
    (license license:gpl3+)))

(define-public emacs-mini-frame
  (package
   (inherit emacs-unfill)
   (name "emacs-mini-frame")
   (version "1.0.0")
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/muffinmad/emacs-mini-frame.git")
                  (commit "41afb3d79cd269726e955ef0896dc077562de0f5")))
            (file-name (git-file-name name version))
            (sha256
             (base32
              "0yghz9pdjsm9v6lbjckm6c5h9ak7iylx8sqgyjwl6nihkpvv4jyp"))))))

(define-public emacs-hide-header-line
  (package
    (inherit emacs-hide-mode-line)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (add-after 'unpack 'make-it-update-header-line
           (lambda* (#:key outputs #:allow-other-keys)
             (substitute* "hide-mode-line.el"
	       ((" mode-line-format")
                " header-line-format"))
             #t)))))))

(define-public emacs-git-email-latest
  (let* ((commit "b5ebade3a48dc0ce0c85699f25800808233c73be")
         (revision "0"))
    (package
      (name "emacs-git-email")
      (version (git-version "0.2.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://git.sr.ht/~yoctocell/git-email")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32
           "1lk1yds7idgawnair8l3s72rgjmh80qmy4kl5wrnqvpmjrmdgvnx"))))
      (build-system emacs-build-system)
      (arguments
       `(#:phases
         (modify-phases %standard-phases
           ;; piem is not yet packaged in Guix.
           (add-after 'unpack 'remove-piem
             (lambda _
               (delete-file "git-email-piem.el")
               (delete-file "git-email-gnus.el")
               (delete-file "git-email-mu4e.el")))
           (add-before 'install 'makeinfo
             (lambda _
               (invoke "makeinfo" "doc/git-email.texi"))))))
      (native-inputs
       `(("texinfo" ,texinfo)))
      (inputs
       `(("emacs-magit" ,emacs-magit)
         ("notmuch" ,emacs-notmuch)))
      (license license:gpl3+)
      (home-page "https://sr.ht/~yoctocell/git-email")
      (synopsis "Format and send Git patches in Emacs")
      (description "This package provides utilities for formatting and
sending Git patches via Email, without leaving Emacs."))))

(define-public emacs-transient-latest
  (let ((commit "72d30284ab75c1497e23be310dcc53a4ecefa401")
        (revision "0"))
    (package
      (inherit emacs-transient)
      (name "emacs-transient")
      (version (git-version "0.3.7" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/magit/transient")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "0qilxy1kmsfr0j177ic7nhyh4lq7s88455bs9iv9j48qrjf7wwcl"))))
      (propagated-inputs
       (modify-inputs (package-propagated-inputs emacs-transient)
         (append emacs-compat))))))

(define-public emacs-git-gutter-transient
  (package
   (name "emacs-git-gutter-transient")
   (version "0.1.0")
   (source
    (local-file "../features/emacs/git-gutter-transient" #:recursive? #t))
   (build-system emacs-build-system)
   (inputs
    `(("emacs-magit" ,emacs-magit)))
   (propagated-inputs
    `(("emacs-git-gutter" ,emacs-git-gutter)
      ("emacs-transient" ,emacs-transient-latest)))
   (license license:gpl3+)
   (home-page "https://sr.ht/~abcdw/git-gutter-transient")
   (synopsis "Navigate, stage and revert hunks with ease")
   (description "This package provides transient interface for git-gutter function
to manipulate and navigate hunks.")))

(define tdlib-latest-instead-of-tdlib
  (package-input-rewriting/spec `(("tdlib-1.8.0" . ,(const tdlib-latest)))))

(define-public emacs-telega-server-latest
  (tdlib-latest-instead-of-tdlib
   (let ((commit "733194c4ed16f57e2b4e66a79be842a5d0731012")
         (revision "0"))
     (package
       (inherit emacs-telega-server)
       (name "emacs-telega-server")
       (version (git-version "0.8.03" revision commit))
       (source
        (origin
          (method git-fetch)
          (uri (git-reference
                (url "https://github.com/zevlg/telega.el")
                (commit "733194c4ed16f57e2b4e66a79be842a5d0731012")))
          (sha256
           (base32 "0l3a2qbqwf6rrnnkranclqq9fig3ki176ddj02azr9360ps46xly"))
          (file-name (git-file-name "emacs-telega" version))
          (patches
           (search-patches "emacs-telega-path-placeholder.patch"
                           "emacs-telega-test-env.patch"))))))))

(define telega-server-latest-instead-of-telega-server
  (package-input-rewriting/spec
   `(("ffmpeg" . ,(const ffmpeg-5))
     ("emacs-telega-server" . ,(const emacs-telega-server-latest)))))

(define-public emacs-telega-latest
  (telega-server-latest-instead-of-telega-server
   (package
     (inherit emacs-telega)
     (version (package-version emacs-telega-server-latest))
     (source (package-source emacs-telega-server-latest)))))

(define-public emacs-telega-contrib-latest
  ;; TODO: Figure out while previous implementation was failing when built
  ;; with grafts.
  (package
    (inherit emacs-telega-latest)
    (name "emacs-telega-contrib")
    (arguments (package-arguments emacs-telega-contrib))
    (inputs '())
    (native-inputs '())
    (propagated-inputs
     (list emacs-alert emacs-all-the-icons emacs-dashboard emacs-telega-latest))
    (synopsis "Contributed packages to Telega")
    (description "Telega-contrib is a collection of third-party
contributed packages to Telega.")))

(define-public emacs-consult-eglot-sans-eglot
  (package
    (inherit emacs-consult-eglot)
    (inputs
     (modify-inputs (package-inputs emacs-consult-eglot)
       (append emacs-eglot)))
    (propagated-inputs
     (modify-inputs (package-propagated-inputs emacs-consult-eglot)
       (delete "emacs-eglot")))))

(define-public emacs-dirvish-latest
  (package
    (inherit emacs-dirvish)
    (propagated-inputs
     (modify-inputs (package-propagated-inputs emacs-dirvish)
       (replace "emacs-transient" emacs-transient-latest)))))

(define-public emacs-docker-latest
  (let ((commit "cc0046e6a557dce0ccc4108dd22e04f21ba8b0dc")
        (revision "0"))
    (package
      (inherit emacs-docker)
      (name "emacs-docker")
      (version (git-version "2.2.0" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/Silex/docker.el")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "11l8jpqj6m04ndhnfz41nhph1rqjvqbfd5vw334mph776aq1baln"))))
      (propagated-inputs
       (modify-inputs (package-propagated-inputs emacs-docker)
         (delete "emacs-docker-tramp")
         (append emacs-transient-latest))))))
