function    conv_old_cues(tag,author,decl)
%
%   conv_old_cues(tag,author,decl)
%
load tag2cues
if ~isfield(CUES,tag),
   fprintf('No old-format cue entry for %s\n',tag);
   return
end
cc = getfield(CUES,tag) ;
savecal(tag,'CUETAB',cc.N)
savecal(tag,'TAGID',cc.id)
savecal(tag,'AUTHOR',author)
savecal(tag,'TAGON',cc.on)
savecal(tag,'DECL',decl)

