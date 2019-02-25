% Checks whether a word reserved by the symbolic toolbox exists in a string

function helperCheckReservedWords( strings, offendingstate )

keywords = {'time','gamma','sin','cos','tan','beta','log','asin','atan','acos','acot','cot','theta','D','x','gradient'};
inter = intersect(strings, keywords);
if(~isempty(inter))
    if ( nargin > 1 )
        error('Fatal error: used reserved word(s) "%s" in the equation of the state "%s" .\nReserved words are: %s\n', sprintf('%s ', inter{:}), offendingstate, sprintf('%s ', keywords{:}) );
    else
        error('Fatal error: used reserved word(s) "%s".\nReserved words are: %s\n', sprintf('%s ', inter{:}), sprintf('%s ', keywords{:}));
    end
end
end