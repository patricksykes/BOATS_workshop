%**************************************************************************************************************
% FUNCTION initialize_output.m
% Defines output "modes". Each mode specifies the variables to be saved, the processing of variables
% (e.g. averages, integrals) and the interval time used for averaging variables (e.g. annual,
% decadal, final timestep, user defined etc.) 
% NOTE: here few defaults examples are included, but output modes could be defined in running scripts
% in a flexible way 
%**************************************************************************************************************
% inputs needed in "output" structure:
% modes : the different output types, each specifiying time intervals, variables, and processing
% Each mode contains:
% t_bounds: [2xN] matrix where N is the number of output timesteps, and each row contains the starting 
%           and ending point of each output timestep average. For example annual output will be:
%           [0 1; 1 2; 2 3; ...]; 5 year averages will be [0 5; 5 10; ...] etc.
%           Note that t_bounds for some default output modes are defined in boats2d_integrate.m :           
%           'all' : monthly times (usually 1 timestep)
%           'annual' : annual averages
%           'decadal' : decadal averages
%           'snap5year' : one annual mean snapshot every 5 years
%           'snap10year' : one annual mean snapshot every 10 years
%           'final' : one annual mean for the last year of integration
%           NOTE: these times will be converted from year to seconds inside boats2d_integrate.m
% var_name : the model variables to be used for the output calculation e.g. 'dfish', 'dharvest', 'effort'
%            repeated as many times as the ways we want them processed and saved in the output
% var_type : '4D' spatial and size e.g. dfish; '3D' spatial only e.g. deffort; 
%            'DER' derived from other OUTPUT variables. Derived variables exist to speed up the 
%            output calculations (e.g. avoid repeating 2D integrals when sums over groups are also required)
% var_proc : processing type for the variable, e.g.
%            'none': saves out the full variable
%            'si': size integral 
%            'gi': group integral 
%            '2di': 2D spatial integral
%            'LMEi': 2D spatial integral across LME only
%            '2di_si': 2D spatial integral 
%            'LMEi_si': 2D spatial integral across LME only 
%            'fishmip': size integral, with all biomass in sizes less than
%            10cm, greater than 10cm (b10) and greater than 30cm (b30).
%            This is to get size-fractionated output for fishmip protocol (Tittensor et al.
%            2018). Combine this with '4D' var_type. Author: RYAN HENEGHAN,
%            JULY 2019
%            NOTE: the postprocessing associated with "var_proc" is defined in boats2d_integrate.m
% var_outn : Output name for the variable (names kept for legacy with David's output names)
% var_derv : for derived variable only (var_type = 'DER'), specifies the original OUTPUT variable
%            that is used for the derived calculation. For non-derived variables, set this to ''. 
%            E.g. in the "annual" output mode, the variable with var_outn = 'fish_LME_gi_t' is 
%            derived (var_type = 'DER') from 'fish_LME_gi_g' (var_derv = 'fish_LME_gi_g') which
%            itself is the LME integral of the size integrated dfish.
%**************************************************************************************************************
function output = initialize_output(inmodes,varargin)

 if nargin==1
    output.modes = {'annual'};
 end

 if ischar(inmodes)
    output.modes = {inmodes};
 elseif iscell(inmodes);
    output.modes = inmodes;
 else
    error(['Output modes not valid']);
 end

 nmodes = length(output.modes);
 
%---------------------------------
% Set different output options
 for indm=1:nmodes
    switch output.modes{indm}
    case 'annual'
        %---------------------------------
        % This output mode matches David's typical output, and contains annual averages
        % of fish, effort and harvests integrated over size classes, with additional 2D integrals, 
        % and 2D integrals summed by groups
        %---------------------------------
        % Define output time range for "annual" mode (leave [] for default) 
        output.annual.t_bounds = [];
        % name of variables to be processed:
        output.annual.var_name = {'dfish','dharvest','effort', ...
                                  'dfish','dharvest','effort', ...
                                  'dfish','dharvest','effort', ...
                                  'dfish','dharvest','effort'};
%                                  'dfish','dharvest','effort', ...
%                                  'dfish','dharvest','effort'};
        % variable type (dimensions, etc.)
        output.annual.var_type = {'4D','4D','3D', ...
                                  'DER','DER','DER', ...
                                  '4D','4D','3D', ...
                                  'DER','DER','DER'};
%                                  '4D','4D','3D', ...
%                                  'DER','DER','DER'};
        % processing type for output (use 'none' or '' to leave as is)
        output.annual.var_proc = {'si','si','none', ...
                                  'gi','gi','gi', ...
                                  '2di_si','2di_si','2di', ...
                                  'gi','gi','gi'};
%                                  'LMEi_si','LMEi_si','LMEi', ...
%                                  'gi','gi','gi'};        
        % name of variable to be saved (leave '' for default name)
        output.annual.var_outn = {'fish_g_out','harvest_g_out','effort_g_out', ...
                                  'fish_t_out','harvest_t_out','effort_t_out', ...
                                  'fish_gi_g','harvest_gi_g','effort_gi_g', ...
                                  'fish_gi_t','harvest_gi_t','effort_gi_t'};
%                                  'fish_LME_gi_g','harvest_LME_gi_g','effort_LME_gi_g', ...
%                                  'fish_LME_gi_t','harvest_LME_gi_t','effort_LME_gi_t'};
        % for derived variables, list the variable used for calculations
        output.annual.var_derv = {'','','', ...
                                  'fish_g_out','harvest_g_out','effort_g_out', ...
                                  '','','', ...
                                  'fish_gi_g','harvest_gi_g','effort_gi_g'};
%                                  '','','', ...
%                                  'fish_LME_gi_g','harvest_LME_gi_g','effort_LME_gi_g'};
    case 'all'
        %RYAN HENEGHAN FISHMIP OUTPUT FOR 2019---------------------------------
        % Output for each month
        % of fish, effort and harvests integrated over size classes, with additional 2D integrals, 
        % and 2D integrals summed by groups
        %---------------------------------
        % Define output time range for "all" mode (leave [] for default) 
        output.all.t_bounds = [];
        % name of variables to be processed:
        output.all.var_name = {'dfish','dharvest','effort', ...
                                  'dfish','dharvest','effort', ...
                                  'dfish','dharvest','effort', ...
                                  'dfish','dharvest','effort'};
%                                  'dfish','dharvest','effort', ...
%                                  'dfish','dharvest','effort'};
        % variable type (dimensions, etc.)
        output.all.var_type = {'4D','4D','3D', ...
                                  '3D','DER','DER', ...
                                  '4D','4D','3D', ...
                                  'DER','DER','DER'};
%                                  '4D','4D','3D', ...
%                                  'DER','DER','DER'};
        % processing type for output (use 'none' or '' to leave as is)
        output.all.var_proc = {'fishmip','si','none', ...
                                  'fishmip_tsb','gi','gi', ...
                                  '2di_si','2di_si','2di', ...
                                  'gi','gi','gi'};
%                                  'LMEi_si','LMEi_si','LMEi', ...
%                                  'gi','gi','gi'};        
        % name of variable to be saved (leave '' for default name)
        output.all.var_outn = {'fishmip_g_out','harvest_g_out','effort_g_out', ...
                                  'fishmip_tsb','harvest_t_out','effort_t_out', ...
                                  'fish_gi_g','harvest_gi_g','effort_gi_g', ...
                                  'fish_gi_t','harvest_gi_t','effort_gi_t'};
%                                  'fish_LME_gi_g','harvest_LME_gi_g','effort_LME_gi_g', ...
%                                  'fish_LME_gi_t','harvest_LME_gi_t','effort_LME_gi_t'};
        % for derived variables, list the variable used for calculations
        output.all.var_derv = {'','','', ...
                                  '','harvest_g_out','effort_g_out', ...
                                  '','','', ...
                                  'fish_gi_g','harvest_gi_g','effort_gi_g'};
%                                  '','','', ...
%                                  'fish_LME_gi_g','harvest_LME_gi_g','effort_LME_gi_g'};
    case 'snap5year'
        %---------------------------------
        % This output mode matches David's typical output, and contains annual averages
        % of fish, effort and harvests integrated over size classes, with additional 2D integrals, 
        % and 2D integrals summed by groups
        %---------------------------------
        % Define output time range for "annual" mode (leave [] for default) 
        output.annual.t_bounds = [];
        % name of variables to be processed:
        output.annual.var_name = {'dfish','dharvest','effort', ...
                                  'dfish','dharvest','effort', ...
                                  'dfish','dharvest','effort', ...
                                  'dfish','dharvest','effort', ...
                                  'dfish','dharvest','effort', ...
                                  'dfish','dharvest','effort'};
        % variable type (dimensions, etc.)
        output.annual.var_type = {'4D','4D','3D', ...
                                  'DER','DER','DER', ...
                                  '4D','4D','3D', ...
                                  '4D','4D','3D', ...
                                  'DER','DER','DER', ...
                                  'DER','DER','DER'};
        % processing type for output (use 'none' or '' to leave as is)
        output.annual.var_proc = {'none','si','none', ...
                                  'gi','gi','gi', ...
                                  '2di_si','2di_si','2di', ...
                                  'LMEi_si','LMEi_si','LMEi', ...
                                  'gi','gi','gi', ...
                                  'gi','gi','gi'};
        % name of variable to be saved (leave '' for default name)
        output.annual.var_outn = {'fish_g_out','harvest_g_out','effort_g_out', ...
                                  'fish_t_out','harvest_t_out','effort_t_out', ...
                                  'fish_gi_g','harvest_gi_g','effort_gi_g', ...
                                  'fish_LME_gi_g','harvest_LME_gi_g','effort_LME_gi_g', ...
                                  'fish_gi_t','harvest_gi_t','effort_gi_t', ...
                                  'fish_LME_gi_t','harvest_LME_gi_t','effort_LME_gi_t'};
        % for derived variables, list the variable used for calculations
        output.annual.var_derv = {'','','', ...
                                  'fish_g_out','harvest_g_out','effort_g_out', ...
                                  '','','', ...
                                  '','','', ...
                                  'fish_gi_g','harvest_gi_g','effort_gi_g', ...
                                  'fish_LME_gi_g','harvest_LME_gi_g','effort_LME_gi_g'};
   case 'final'
        %---------------------------------
        % This output mode saves only dfish averaged for the last year of model integration
        %---------------------------------
        % Define output for "final" mode (leave [] for default) 
        output.final.t_bounds = [];
        % name of variables to be processed:
        output.final.var_name = {'dfish'};
        % variable type (dimensions, etc.)
        output.final.var_type = {'4D'};
        % processing type for output (use 'none' or '' to leave as is)
        output.final.var_proc = {'none'};
        % name of variable to be saved (leave '' for default name)
        output.final.var_outn = {'dfish'};
        %---------------------------------
        %---------------------------------
        %---------------------------------
    otherwise
        error(['Mode ' output.modes{indm} ' has not been defined']);
    end
 end
 
%**************************************************************************************************************
% END FUNCTION



