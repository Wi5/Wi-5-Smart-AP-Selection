classdef create_AP < handle
    properties
        ID
        location_x = [];
        location_y = [];
        CH_n = [];
        freq
        tx_pwr
%         AP_BR = 0;
        AP_stations = 0;
    end
    
    methods
        function obj = create_AP(u_,parameters,varargin)
            if (nargin < 2 || nargin > 5)
                error('myApp:argChk','use create_APs(u_,parameters,location_x,location_y,CH_n) to create APs. Leave the unused variables as []')
            else
                if nargin>4 && varargin{3}~=[]
                    obj.CH_n=varargin{3};
                elseif nargin>3 && varargin{2}~=[]
                    obj.location_y=varargin{2};
                elseif nargin>2 && varargin{1}~=[]
                    obj.location_x=varargin{1};                
                end
            end
            if isequal(obj.location_x, [])
              obj.location_x = parameters.APs_locations(u_,1);
            end
            if isequal(obj.location_y, [])
              obj.location_y = parameters.APs_locations(u_,2);
            end
            if isequal(obj.CH_n, [])
              obj.CH_n = randi(11);
            end
            obj.ID = u_;
            obj.freq  = parameters.freq(obj.CH_n);
            obj.tx_pwr = parameters.APsInitTxPwr; 
        end
        
        function set_CH_n(obj, n)
          obj.CH_n=n;
        end

    end
end