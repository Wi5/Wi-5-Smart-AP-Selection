function G_opt = set_APpwr (G, O_l, Assignment)
N=length(G);
for i=1:N
    for j=1:N
        k=(i-1)*N+j;
        if G(i,j)~=0
            c(k)=Assignment(j,:)*O_l(:,i);
        else
            c(k)=1000;
        end
    end
    b_values(i)=sum(G(i,:));
end
c_temp=(reshape(c,N,N))';

A=reshape(repmat(reshape(eye(N,N)',1,[]),N,1),[],size(eye(N,N),1))';
pwr_reduction=0.6;
b=pwr_reduction*b_values;

G_vec= reshape(G,[],1);
lb=0.5*G_vec;
ub=1.5*G_vec;
xmin = linprog(c,A,b,[],[],lb,ub);
% ctype = "LLLLLLLLL";
%vartype = "CCCCCCCCCCCC";
% s = 1;
%
% param.msglev = 1;
% param.itlim = 1000;
%
% [xmin, fmin, status, extra] = ...
%   glpk (c, A, b, lb, ub,[], [], s, param);

G_opt=(reshape(xmin,N,N))';

% G_comparison=[G_vec xmin];
% cost_comp=[pwr_reduction sum(diag(G*Assignment*O_l)) sum(diag(G_opt*Assignment*O_l))]
end