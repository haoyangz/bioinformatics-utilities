require('ROCR')
require('caTools')
rocprc <- function(pred,label,outdir){
sample_num = length(pred)
model <- prediction(pred, label)

roc_perf <- performance(model,"tpr","fpr")
auroc_perf <- performance(model,'auc')
meanauroc = mean(unlist(auroc_perf@y.values))
print(paste0('auroc: ',meanauroc))
pdf(file.path(outdir,'roc.pdf'))
plot(roc_perf,avg='vertical',col="red",lty=1,spread.estimate='stderror')
legend(x=0.7,y=0.2,legend=meanauroc)
dev.off()

prc_perf <- performance(model,"prec","rec")
auprc_perf <- sapply(1:sample_num,function(i){
				   pick = !is.na(prc_perf@x.values[[i]]) & !is.na(prc_perf@y.values[[i]])
				   trapz(prc_perf@x.values[[i]][pick],prc_perf@y.values[[i]][pick])})
meanauprc = mean(auprc_perf)
print(paste0('auprc: ',meanauprc))
pdf(file.path(outdir,'prc.pdf'))
plot(prc_perf,avg='vertical',col="red",lty=1,spread.estimate='stderror',spread.scale =1.96,xlim=c(0,1), ylim=c(0,1))
legend(x=0.7,y=0.2,legend=meanauprc)
dev.off()

save(roc_perf,auroc_perf,prc_perf,auprc_perf,file=file.path(outdir,'perf.RData'))

}
