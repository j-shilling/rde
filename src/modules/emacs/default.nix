{ config, lib, pkgs, inputs, username, ... }:
with lib;
let
  hm = config.home-manager.users.${username};
  emacs-with-pkgs =
    (pkgs.unstable.emacsPackagesGen pkgs.unstable.emacsGit).emacsWithPackages;
  cfg = config.rde.emacs;

  # Source: https://gitlab.com/rycee/nur-expressions/-/blob/master/hm-modules/emacs-init.nix#L9
  packageFunctionType = mkOptionType {
    name = "packageFunction";
    description =
      "Function returning list of packages, like epkgs: [ epkgs.org ]";
    check = isFunction;
    merge = mergeOneOption;
  };

  varType = types.submodule ({ name, config, ... }: {
    options = {
      value = mkOption { type = types.either types.str (types.either types.int types.bool); };
      docstring = mkOption {
        type = types.str;
        default = "";
      };
    };
  });

  varSetToConfig = v:
    let
      dispatcher = { bool = v: if v then "t" else "nil";
                     string = v: ''"${v}"'';};

      valueToStr = v:
        ((attrByPath [(builtins.typeOf v)] toString dispatcher) v);
      ifDocString = v:
        if (stringLength v.docstring > 0) then " \"${v.docstring}\"" else "";
      tmp = mapAttrsToList (name: value: ''
        (defvar ${name} ${valueToStr value.value}${ifDocString value})
      '') v;
    in concatStrings tmp;

  configSetToConfig = v:
    let tmp = mapAttrsToList (name: value: "${value.config}") v;
    in concatStrings tmp;

  emacsConfigType = types.submodule ({ name, config, ... }: {
    options = {
      enable = mkEnableOption "Enable emacs.configs.${name}.";
      vars = mkOption {
        type = types.attrsOf varType;
        description = "Variable declaration for emacs.configs.${name}.";
      };
      packages = mkOption {
        type =
          # types.either
          # ((types.listOf types.str) // { description = "List of packages."; })
          packageFunctionType;
        default = epkgs: [ ];
        description = ''
          Emacs package list for this config.
        '';
        example = "epkgs: [ epkgs.org ]";
      };
      config = mkOption {
        type = types.lines;
        description = ''
          Use-package configuration for ${name}.
        '';
      };
      systemPackages = mkOption {
        type = types.listOf types.package;
        description = "System dependencies for ${name}.";
      };

    };
    config = mkIf config.enable {
      vars = {
        "rde/config-${name}-enabled".value = true;
      };
    };
  });

  mkROFileOption = path:
    (mkOption {
      type = types.path;
      description = "Files autogenerated by rde";
      default = path;
      readOnly = true;
    });
in {

  imports = [ ];
  options = {
    rde.emacs = {
      enable = mkEnableOption "Enable rde emacs";
      dir = mkOption {
        type = types.path;
        description =
          "Directory, where emacs configuration files will be placed.";
        default =
          "${config.home-manager.users.${username}.xdg.configHome}/emacs";
      };
      files = {
        init = mkROFileOption "${config.rde.emacs.dir}/init.el";
        early-init = mkROFileOption "${config.rde.emacs.dir}/early-init.el";
        custom = mkOption {
          type = types.path;
          description = "Path to custom.el.";
          default = "${
              config.home-manager.users.${username}.xdg.dataHome
            }/emacs/custom.el";
        };
      };

      # user-init = mkOption {
      #   type = types.path;
      #   description = "Can source"
      #   default = "${config.rde.emacs.dir}/user.el";
      # };
      # custom-file = mkFileOption "${config.rde.emacs.dir}/custom.el";

      # config = mkOption {
      #   type = types.lines;
      #   description = ''
      #     Every config adds use-package declaration(s) here.
      #     Don't use it for user defined configurations.'';
      #   default = "";
      # };

      configs = mkOption {
        type = types.attrsOf emacsConfigType;
        description = "Configurations for various packages or package sets";
      };

      vars = mkOption {
        type = types.attrsOf varType;
        description = "Every config adds variable declaration(s) here.";
      };

      font = mkOption {
        type = types.str;
        default = config.rde.font;
      };
      fontSize = mkOption {
        type = types.int;
        default = config.rde.fontSize;
      };

    };
  };

  config = mkIf config.rde.emacs.enable {
    rde.emacs.vars = {
      "rde/username" = {
        value = username;
        docstring = "System username provided by rde.";
      };
      "rde/custom-file" = {
        value = cfg.files.custom;
        docstring = "Path to custom.el.";
      };
      "rde/font-family".value = cfg.font;
      "rde/font-size".value = cfg.fontSize;
    };
    rde.emacs.configs = {
      org-roam = {
        enable = true;
        vars = {
          "rde/org-roam-directory".value =
            "${config.rde.workDir}/org-files/notes";
        };
        config = ''
          (use-package org-roam
            :hook
            (after-init-hook . org-roam-mode)
            :config
            (setq org-roam-directory rde/org-roam-directory)
            :bind (
          	 :map org-roam-mode-map
                   (("C-c n l" . org-roam)
                    ("C-c n f" . org-roam-find-file)
                    ("C-c n g" . org-roam-graph-show))
                   :map org-mode-map
                   (("C-c n i" . org-roam-insert))
                   (("C-c n I" . org-roam-insert-immediate))))
        '';
        packages = epkgs: [ epkgs.org-roam ];
        systemPackages = [ pkgs.sqlite ];
      };
    };
    home-manager.users."${username}" = {
      home.file."${cfg.files.init}".text = ''
        (require 'rde-variables)
        (require 'rde-configs)
        (provide 'init)
      '';
      home.file."${cfg.files.early-init}".source = ./early-init.el;

      home.packages = with pkgs;
        let
          emacsConfigs = filterAttrs (n: v: v.enable) cfg.configs;
          systemPackageList = flatten
            (mapAttrsToList (key: value: value.systemPackages) emacsConfigs);
        in systemPackageList ++ [
          emacs-all-the-icons-fonts
          (emacs-with-pkgs (epkgs:
            let
              build-emacs-package = pname: text:
                (epkgs.trivialBuild {
                  pname = pname;
                  version = "1.0";
                  src = pkgs.writeText "${pname}.el" text;
                  packageRequires = [ epkgs.use-package ];
                  preferLocalBuild = true;
                  allowSubstitutes = false;
                });

              concatVarSets = configs:
                let
                  tmp = mapAttrsToList (key: value:
                    ''
                      ;;; Variables by configs.${key}
                    '' + (varSetToConfig value.vars)) configs;
                in concatStrings tmp;
              rde-variables-text = (varSetToConfig cfg.vars)
                + (concatVarSets emacsConfigs) + ''

                  (provide 'rde-variables)
                '';
              rde-variables-package =
                build-emacs-package "rde-variables" rde-variables-text;

              rde-configs-text = (readFile ./rde-configs.el)
                + configSetToConfig emacsConfigs + "(provide 'rde-configs)";
              rde-configs-package =
                build-emacs-package "rde-configs" rde-configs-text;

              packageList = flatten
                (mapAttrsToList (key: value: (value.packages epkgs))
                  emacsConfigs);
            in with epkgs;
            packageList ++ [
              rde-variables-package
              rde-configs-package
              use-package
              nix-mode
              magit
              modus-operandi-theme
              org
              company-org-roam
              company
              ivy
              olivetti
              restart-emacs
              keycast
            ]))
        ];
    };
  };
}
