function objects = calculateParameterCombination(handles, objects, params)

ticValue = displayTime;

filterExpr = params.edit_parameterCombination_formula;
newName = params.edit_parameterCombination_newParamName;

formulaRaw = filterExpr;
try
    fields = extractBetween(formulaRaw,'{','}');
catch
    fields = regexp(formulaRaw, '{.*?}', 'match');
    fields = cellfun(@(x) x(2:end-1), fields, 'UniformOutput', false);
end
formula = formulaRaw;
if ~isempty(fields)
    %%% replace /, *, ^
    formula = strrep(formula, '/', './');
    formula = strrep(formula, '*', '.*');
    formula = strrep(formula, '^', '.^');
    for i = 1:numel(fields)
        formula = strrep(formula, ['{', fields{i}, '}'], sprintf('[objects.stats.%s]', fields{i}));
    end
else
    formula = formulaRaw;
end

eval(sprintf('result = %s;', formula));

result = num2cell(double(result));
[objects.stats.(sprintf('%s', newName))] = result{:};



displayTime(ticValue);