#include "mex.h"
#include "mat.h"

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  const char **var_names;
  mwSize dims[2];
  int n_vars;
  int i;
  
  MATFile *mf = matOpen(mxArrayToString(prhs[0]), "r");
    
  var_names = (const char **)matGetDir(mf, &n_vars);
  
  dims[0] = 1;
  dims[1] = n_vars;
  plhs[0] = mxCreateCellArray( (mwSize) 2, dims);
  
  for(i = 0;i<n_vars;i++){
      mxSetCell(plhs[0],i,mxCreateString(var_names[i]));
  }
  
  matClose(mf);
}