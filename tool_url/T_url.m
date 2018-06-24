switch tid
    case 0.1
        % opt=3;dopt=5.1;p_para;
        % simple API: many don't work ...
        % fn='wget "http://archive.org/wayback/available?url=%s&timestamp=19950101" -O data/wayback/result/%d/%s.txt && sleep 5;';
        % bad: may have 404 error and empty file...
        fn='wget "http://web.archive.org/web/1995/%s" -o data/wayback/start_result2/%d/%s.txt && sleep 5;';
        nn='20k';pref=100;suf='_none';
        vv=U_tr(['data/good_urls_' nn '_g2' suf '.csv'],'\n');
        out=cell(1,numel(vv));
        num=20;
        load(['data/good_urls_' nn '_g2_ind'],'mm')
        for i=1:numel(vv)
            out{i} = sprintf(fn,vv{i},mm(vv{i}),vv{i});
        end
        for i=1:num
            sn = ['data/wayback/query/dw_' num2str(pref+i) '.sh'];
            U_out(sn,{'#!/bin/bash'});
            U_out(sn,out(i:num:end),-1);
            system(['chmod +x ' sn]);
        end
    case 0.21 % result2 -> result
        nn='12k';
        nn='20k';
        suf='';
        %suf='_none';
        load(['data/good_urls_' nn '_g2_ind'],'mm')
        % parse: html file
        %vv=U_tr('data/good_urls_12k_g2_todo.csv','\n');opt=1;
        % parse: wget log
        %vv=U_tr('data/good_urls_12k_g2_none.csv','\n');opt=2;
        vv=U_tr(['data/good_urls_' nn '_g2' suf '.csv'],'\n');opt=2;
        fn='{"archived_snapshots":{"closest":{"available":true,"url":"http://web.archive.org/web/%s/http://%s:80/","timestamp":"%s","status":"200"}}}';
        ind2=cell(1,3);
        nn2={'web/199','web/200','web/201'};
        bb=ones(1,numel(vv));
        for i=1:numel(vv)
            a=textread(sprintf('data/wayback/start_result2/%d/%s.txt',mm(vv{i}),vv{i}),'%s','delimiter','\n','bufsize',1e7);
            if numel(a)>3
                switch opt
                case 1
                case 2;a(1:3)=[];
                end
                ind = find([cellfun(@(x)  numel(strfind(x,'web/199'))+numel(strfind(x,'web/200'))+numel(strfind(x,'web/201')),a)]);
                ind = setdiff(ind,find([cellfun(@(x)  numel(strfind(x,'link rel')),a)]));
                ind = setdiff(ind,find([cellfun(@(x)  numel(strfind(x,'.js')),a)]));
                ind = setdiff(ind,find([cellfun(@(x)  numel(strfind(x,'im_/')),a)]));
                if numel(ind)>0
                    b=a{ind(1)};
                    for k=1:3;ind2{k} = strfind(b,nn2{k});end
                    tt=[ind2{:}];
                    ts=b(tt(1)+(0:13));
                    bb(i)=0;
                end
                if bb(i)==0
                    U_out(sprintf('data/wayback/start_result/%d/%s.txt',mm(vv{i}),vv{i}),{sprintf(fn,ts,vv{i},ts)});
                end
            end
            if opt==1;
                U_out(['data/good_urls_' nn '_g2_none.csv'],vv(bb==1))
            end
        end
    case 0.22
        nn='12k';
        nn='20k';
        v1=U_tr(['data/good_urls_' nn '_g2.csv'],'\n');
        v2=U_tr(['data/good_urls_' nn '_g2_none.csv'],'\n');
        bid=ismember(v1,v2);
        U_out(['data/good_urls_' nn '_g3.csv'],v1(~bid))
    case 0.2 % wayback result
        nn='12k';
        nn='20k';
        load(['data/good_urls_' nn '_g2_ind'],'mm')
        %vv=U_tr('data/good_urls_12k_g2.csv','\n');
        vv=U_tr(['data/good_urls_' nn '_g3.csv'],'\n');
        out=cell(1,numel(vv));
        num=20;
        bb=zeros(size(vv));
        for i=1:numel(vv)
            a=U_tr(sprintf(['data/wayback/start_result/%d/%s.txt'],mm(vv{i}),vv{i}),'\n');
            ind=strfind(a{1},'timestamp');
            if isempty(ind)
                bb(i)=1;
            else
                tmp=a{1}(ind+12:end);
                if tmp(1)=='w'
                    out{i}=tmp(5:10);
                else
                    out{i}=tmp(1:6);
                end
            end
        end
        if nnz(bb)>0
            U_out(['data/good_urls_' nn '_g2_todo.csv'],vv(bb==1));
        else%ready to populate todo_result
            U_out(['data/good_urls_' nn '_g3_start.csv'],out);
        end
    case 0.222 % check _start.csv, may not be right format
        vv = U_tr(['data/good_urls_' nn '_g3_start.csv'],'\n');
        b1 = find(cellfun(@length,vv)~=6);
        rr=zeros(size(vv));
        for i=1:numel(vv)
            rr(i)=numel(str2num(vv{i}));
        end
    case 0.23 % divide into folders 
        nn='12k';
        nn='20k';
        vv=U_tr(['data/good_urls_' nn '_g2.csv'],'\n');
        ind=mod(1:numel(vv),20)+1;
        mm=containers.Map(vv,ind);
        save(['data/good_urls_' nn '_g2_ind'],'mm','-v7.3')
    case 0.3 % previously download result
        bb=U_tr('bad','\n');
        nn={'_kw','_miss'};
        vv=cell(3,2);
        dd=cell(3,2);
        opt=1;suf='';% only url index
        opt=2;suf='_p';% path
        for i=1:3
            for j=1:2
                t1=U_tr([DD0 'bk/v' num2str(i) nn{j} '.txt'],'\n');
                t2=U_cf(@(x) x(U_ff(x,'_')+5:end),t1);
                switch opt
                case 1;t3=U_cf(@(x) x(1:14),t1);
                case 2;
                    if j==1;t3=U_cf(@(x) ['data_v' num2str(i) '/' x(1:4) '/' x(5:6) '/' x],t1);
                    else;t3=U_cf(@(x) ['missImg/' x(1:4) '/' x(5:6) '/' x],t1);
                    end
                end
                if j==2;
                    for k=1:2;t2=U_cf(@(x) x(1:U_fl(x,'_')-1),t2);end
                end
                gid = ~ismember(t2,bb); 
                vv{i,j} = t2(gid); 
                dd{i,j} = t3(gid); 
            end
        end
        v0=cat(1,vv{:});
        d0=cat(1,dd{:});
        % U_out('data/dw_v1-3.txt',d0);
        [a,~,b]=unique(v0);
        %v2=U_tr('data/good_urls_12k_g2.csv','\n');
        v2=U_tr('data/good_urls_12k_g3.csv','\n');
        mm=[];load('data/good_urls_12k_g2_ind','mm')
        num=20;
        % 497221
        for i=1:numel(v2)
            ind=find(ismember(a,{strrep(v2{i},'.','_')}));
            if numel(ind)>0
                U_out(sprintf('data/wayback/download/%d/%s.txt',mm(v2{i}),[v2{i} suf]),sort(d0(b==ind)));
            end
        end
    case 0.4 % compare number
        % downloaded: 441,975
        nn='12k';
        nn='20k';
        mm=[];load(['data/good_urls_' nn '_g2_ind'],'mm')
        vv=U_tr(['data/good_urls_' nn '_g3.csv'],'\n');
        cc=zeros(size(vv));
        num=20;
        parfor i=1:numel(cc)
            sn=sprintf('data/wayback/download/%d/%s.txt',mm(vv{i}),vv{i});
            if exist(sn,'file')
                cc(i)=numel(U_tr(sn,'\n'));
            end
        end
        dlmwrite(['data/good_urls_' nn '_g3_dw.csv'],cc);
    case 0.41
        % to download
        nn='12k';
        nn='20k';
        vv=U_tr(['data/good_urls_' nn '_g3.csv'],'\n');
        st=load(['data/good_urls_' nn '_g3_start.csv']);
        cc=zeros(size(vv));
        num=20;
        % -2018.05
        ind = reshape(bsxfun(@plus,(1996:2016)'*100,1:12)',1,[]);
        % -2018.05
        ind = reshape(bsxfun(@plus,(1996:2018)'*100,1:12)',1,[]);ind(end-6:end)=[];
        mm=[];load(['data/good_urls_' nn '_g2_ind'],'mm')
        parfor i=1:numel(cc)
            sid=U_ff(ind,st(i));
            out=ind(sid:end);
            sn=sprintf('data/wayback/download/%d/%s.txt',mm(vv{i}),vv{i});
            try
                if exist(sn,'file')
                    dw=unique([cellfun(@(x) str2num(x(1:6)),U_tr(sn,'\n'))]);
                    out=setdiff(out,dw);
                end
                sn2=sprintf('data/wayback/todo/%d/%s.txt',mm(vv{i}),vv{i});
                U_out(sn2,U_af(@(x) num2str(out(x)),(1:numel(out))'))
                cc(i)=numel(out);
            catch
                sn
            end
        end
        dlmwrite(['data/good_urls_' nn '_g3_todo.csv'],cc);
    case 0.411 % d2
        % to download
        suf='_d2';
        nn='12k';
        %nn='20k';
        vv=U_tr(['data/good_urls_' nn '_g3.csv'],'\n');
        % -2018.06
        ind = reshape(bsxfun(@plus,(2017:2018)'*100,1:12)',1,[]);ind(end-5:end)=[];
        cc=numel(ind)*ones(size(vv));
        num=20;
        mm=[];load(['data/good_urls_' nn '_g2_ind'],'mm')
        parfor i=1:numel(cc)
            out=ind;
            sn2=sprintf('data/wayback/todo/%d/%s.txt',mm(vv{i}),[vv{i} suf]);
            U_out(sn2,U_af(@(x) num2str(out(x)),(1:numel(out))'))
        end
        dlmwrite(['data/good_urls_' nn '_g3_todo' suf '.csv'],cc);
    case 0.42 
        % generate query download
        % old: g3_todo.txt=d1-20k
        redo=1; % 1: check done
        suf=''; % d1: 199601-201612

        redo=0; % 0: do all
        suf='_d2'; % d2: 201701-201806
        nns={'12k','20k'};
        for nid=1:2
            nn=nns{nid};
            sn=['data/wayback/g3_todo' suf '_' nn '.txt'];

            vv=U_tr(['data/good_urls_' nn '_g3.csv'],'\n');
            mm=[];load(['data/good_urls_' nn '_g2_ind'],'mm')
            fn='wget "http://web.archive.org/web/%d15/%s" -o data/wayback/todo_result/%d/%s/%s_%d.txt -O /dev/null && sleep 5;\n';
            out='data/wayback/todo_result/%d/%s/%s_%d.txt';
            oo=cell(size(vv));
            if redo==1
                for i=1:numel(vv)
                    yy=load(sprintf('data/wayback/todo/%d/%s.txt',mm(vv{i}),[vv{i} suf]));
                    oo2=cell(size(yy));
                    %for j=1:numel(yy)
                    parfor j=1:numel(yy)
                        out2=sprintf(out,mm(vv{i}),vv{i},vv{i},yy(j));
                        if ~exist(out2,'file')
                            oo2{j}=sprintf(fn,yy(j),vv{i},mm(vv{i}),vv{i},vv{i},yy(j));
                        end
                    end
                    oo{i}=cat(1,oo2{:});
                end
            else
                parfor i=1:numel(vv)
                    yy=load(sprintf('data/wayback/todo/%d/%s.txt',mm(vv{i}),[vv{i} suf]));
                    oo2=U_af(@(j) sprintf(fn,yy(j),vv{i},mm(vv{i}),vv{i},vv{i},yy(j)),1:numel(yy));
                    oo{i}=cat(1,oo2{:});
                end
            end
            U_out(sn,oo,1);
        end
    case 0.44 % mkdir
        nn='12k';
        nn='20k';
        vv=U_tr(['data/good_urls_' nn '_g3.csv'],'\n');
        mm=[];load(['data/good_urls_' nn '_g2_ind'],'mm')
        fid=fopen('tmp.sh','w');
        for i=1:numel(vv)
            %fprintf(fid,'mv data/wayback/todo_result/%d/%s_* data/wayback/todo_result/%d/%s/ \n',mm(vv{i}),vv{i},mm(vv{i}),vv{i});
            U_mkdir(sprintf('data/wayback/todo_result/%d/%s',mm(vv{i}),vv{i}))
        end
        fclose(fid);
    case 0.43 % para-job
        % opt=3;dopt=5.1;p_para;
        %vv=U_tr('data/wayback/g3_todo.txt','\n');pref=100;
        %suf='_d2';pref=200;
        suf='';pref=300;
        vv=cat(1,U_tr(['data/wayback/g3_todo' suf '_12k.txt'],'\n'), U_tr(['data/wayback/g3_todo' suf '_20k.txt'],'\n'));
        num=25;
        for i=1:num
            sn = ['data/wayback/query/dw_' num2str(pref+i) '.sh'];
            U_out(sn,{'#!/bin/bash'});
            U_out(sn,vv(i:num:end),-2);
            system(['chmod +x ' sn]);
        end
    case 0.5 %% urls to re-download: wrong year & no url found
        vv=U_tr('data/good_urls_12k_g3.csv','\n');
        mm=[];load('data/good_urls_12k_g2_ind','mm')
        sn='data/wayback/g3_todo_redo.txt';
        fn='wget "http://web.archive.org/web/%d15/%s" -o data/wayback/todo_result/%d/%s/%s_%d.txt -O /dev/null && sleep 5;\n';
        out='data/wayback/todo_result/%d/%s/%s_%d.txt';
        oo = cell(size(vv));
        %for i=1:numel(vv)
        parfor i=1:numel(vv)
            yy=U_tr(sprintf('data/wayback/todo_result/%d/%s.txt',mm(vv{i}),vv{i}),'\n');
            ll=find(cellfun(@length,yy)==1);
            if ~isempty(ll)
                xx=load(sprintf('data/wayback/todo/%d/%s.txt',mm(vv{i}),vv{i}));
                oo2=cell(size(ll));
                for j=1:numel(ll)
                    oo2{j}=sprintf(fn,xx(ll(j)),vv{i},mm(vv{i}),vv{i},vv{i},xx(ll(j)));
                end
                oo{i}=cat(1,oo2{:});
            end
        end
        U_out(sn,cat(1,oo(:)),1);
    case 0.51 % make sure no location -> check if bug.. [todo/ todo_result/ different length] 
        sn='data/wayback/g3_todo_redo.txt';
        sn2='data/wayback/g3_todo_redo2.txt';
        vv=U_tr(sn,'\n');
        vv(cellfun(@length,vv)==0)=[];
        sc=zeros(size(vv));
        parfor i=1:numel(vv)
            a=strsplit(vv{i},' ');
            vin=textread(a{4},'%s','delimiter','\n');
            ind=find([cellfun(@(x) numel(strfind(x,'Location'))>0,vin)]);
            if isempty(ind)
                sc(i)=1;
            end
        end
        U_out(sn2,vv(sc==1));
    case 0.6 %% urls todo download: check month agrees
        vv=U_tr('data/good_urls_12k_g3.csv','\n');
        mm=[];load('data/good_urls_12k_g2_ind','mm')
        sn='data/wayback/g3_ali_url1.txt';
        oo = cell(size(vv));
        parfor i=1:numel(vv)
            yy=U_tr(sprintf('data/wayback/todo_result/%d/%s.txt',mm(vv{i}),vv{i}),'\n');
            xx=U_tr(sprintf('data/wayback/todo/%d/%s.txt',mm(vv{i}),vv{i}),'\n');
            gid = [arrayfun(@(x) numel(strfind(yy{x},['/' xx{x}]))>0,1:numel(xx))];
            oo{i}=yy(gid);
            
            %remove %,#
            bid=[cellfun(@(x) nnz(x=='#')>0,oo{i})];
            oo{i}(bid) = U_cf(@(x) x(1:U_ff(x,'#')-1),oo{i}(bid));
            bid=[cellfun(@(x) nnz(x=='%')>0,oo{i})];
            oo{i}(bid) = U_cf(@(x) x(1:U_ff(x,'%')-1),oo{i}(bid));
        end
        U_out(sn,cat(1,oo{:}));
    case 0.62 % miss plugin
        sn='data/wayback/g3_ali_url2.txt';
        % redo
        nn={'bk/v1_kw_u_plugin','bk/v2_kw_u_plugin','bk/v3_kw_u_plugin','data_v10_bad_5mp','data_v10_bad_3mp','data_v12_bad_2mp','data_v12_bad_3mp'};
        out=cell(1,numel(nn));
        % file name -> html
        fn='';
        fn='http://web.archive.org/web/%s/http://%s';
        for i=1:numel(nn)
            tmp = U_tr([DD0 nn{i} '.txt'],'\n');
            if nnz(tmp{1}=='/')
                tmp=U_cf(@(x) x(U_fl(x,'/')+1:end),tmp);
            end
            if strcmp(tmp{1}(end-2:end),'png')
                tmp=U_cf(@(x) x(1:end-4),tmp);
            end
            t1 = U_cf(@(x) x(1:14),tmp);
            t2 = U_cf(@(x) strrep(x(16:end),'_','.'),tmp);
            out{i} = U_af(@(x) sprintf(fn,t1{x},t2{x}),(1:numel(t1))'); 
            out{i}{1}
        end
        U_out(sn,cat(1,out{:}));
    end
case 5
    % output url into txt files
    switch tid
    case 2.1
        v1=U_tr(['data/wayback/g3_ali_url1.txt'],'\n');
        v1=cat(1,v1,U_tr(['data/wayback/g3_ali_url2.txt'],'\n'));
        numMachine = 20;
        numRound = 50;
        num=ceil(numel(v1)/numRound/numMachine);
        cc=1;
        for i=1:numMachine
            for j=1:numRound
                ind=((cc-1)*num+1):min(numel(v1),cc*num);
                U_out(sprintf('data/wayback/ali_crawl/inputWorkingUrls_%03d_%02d.txt',j-1,i-1),v1(ind));
                cc=cc+1;
            end
        end
    end
end
