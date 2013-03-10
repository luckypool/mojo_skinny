(function(){

    var FIND_REQUEST_PARAMS = {
        limit  : 12,
        offset : 0,
        order  : "DESC"
    };

    function Background(){
        this.initialize.apply(this, arguments);
    }
    Background.prototype = {
        initialize:function(arguments) {
            this.model = {
                lookup : new Model({method:"lookup"}),
                count  : new Model({method:"count"}),
                create : new Model({method:"create"}),
                delete : new Model({method:"delete"}),
                find   : new Model({method:"find"})
            };
            this.view = new View();
            this.assignFormsAndEvents();
            this.loadInitialContents();
        },
        assignFormsAndEvents:function(){
            this.view.assignShowMoreButton('showMore','もっと見る');
            this.assignShowMoreEvent('showMore');

            this.view.assignPostButton('postTag1','あああああああああああ');
            this.view.assignModalWindow('postTag1',1,"ああああああ","ああ");
            this.assignPostEvent('postTag1');

            this.view.assignPostButton('postTag2','いいいいいいいいいいい');
            this.view.assignModalWindow('postTag2',2,"いいい1","iii");
            this.assignPostEvent('postTag2');

            this.view.assignPostButton('postTag3','ううううううううううう');
            this.view.assignModalWindow('postTag3',3,"Ultuuuuu","uuuu");
            this.assignPostEvent('postTag3');

            $('a[rel*=leanModal]').leanModal();
        },
        assignShowMoreEvent:function(idName){
            var _self = this;
            $('#'+idName).click(function(evt){
                $('#'+idName).attr("disabled","disabled");
                _self.getRemainedEntries(idName)
                .done(function(entries){
                    $.each(entries, function(i, entry){
                        _self.view.appendEntity(new Entity(entry));
                    });
                    $('#'+idName).removeAttr("disabled");
                });
            });
        },
        getRemainedEntries:function(idName){
            var _self = this;
            var df = $.Deferred();
            this.getRemainedEntryCount().done(function(res){
                var params = {
                    limit  : 6,
                    offset : res - 6,
                    order  : "ASC"
                };
                if(res-6<0){
                    params.limit  = res;
                    params.offset = 0;
                    $('#'+idName).attr("disabled","disabled").text("すべて読み込みました");
                }
                _self.model.find.request(params).done(function(res){
                    if(res.error){
                        df.reject(res.error);
                    } else {
                        df.resolve(res.result.reverse());
                    }
                });
            });
            return df.promise();
        },
        getRemainedEntryCount:function(){
            var df = $.Deferred();
            var currentCount = $('#contents_area_main').find('.container').size();
            this.model.count.request({})
            .done(function(res){
                if(res.error){
                    df.reject(res.error);
                } else {
                    var remained = res.result - currentCount;
                    remained <= 0 ? df.reject() : df.resolve(remained);
                }
            });
            return df.promise();
        },
        assignPostEvent:function(prefix){
            var _self = this;
            var elements = {
                submit   : $("#"+prefix+"-submit"),
                body     : $("#"+prefix+"-body"),
                nickname : $("#"+prefix+"-nickname"),
                tag      : $("#"+prefix+"-tag")
            };
            elements.submit.click(function(evt){
                elements.nickname.attr("disabled","disabled");
                elements.submit.attr("disabled","disabled");
                elements.body.attr("disabled","disabled");
                $("#loading_overlay").show();
                _self.postEntry(elements)
                .done(function(res){
                    _self.view.prependEntity(new Entity(res));
                    elements.nickname.val("名無しさん");
                    elements.body.val("");
                }).fail(function(res){
                    console.log(res);
                    alert(res.error.message);
                }).always(function(){
                    elements.nickname.removeAttr("disabled");
                    elements.submit.removeAttr("disabled");
                    elements.body.removeAttr("disabled");
                    $("#loading_overlay").hide();
                    $("#lean_overlay").click();
                });
            });
        },
        postEntry:function(elements){
            var df = $.Deferred();
            this.model.create.request({
                nickname: elements.nickname.val(),
                body    : escapeHTML(elements.body.val()),
                tag_id  : elements.tag.val()
            }).done(function(response){
                if("error" in response){
                    df.reject(response);
                } else {
                    df.resolve(response.result);
                }
            });
            return df.promise();
        },
        loadInitialContents:function(){
            var _self = this;
            this.model.find.request(FIND_REQUEST_PARAMS)
            .done(function(response){
                $.each(response.result, function(i, entry){
                    _self.view.appendEntity(new Entity(entry));
                });
            });
        }
    };

    function escapeHTML(str) {
          return str.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
    }

    function View(){
        this.initialize.apply(this, arguments);
    }
    View.prototype = {
        initialize:function(arguments) {
            var baseHtml = $('#container_template').html();
            var linkHtml = '<a class="css_btn_class" >${buttonText}</a>';
            var buttonHtml = '<button class="css_btn_class" type="button">${buttonText}</button>';
            var modalWindowHtml = $('#post_template').html();
            $.template("containerTemplate", baseHtml);
            $.template("buttonTemplate", buttonHtml);
            $.template("postLinkTemplate", linkHtml);
            $.template("modalWindowTemplate", modalWindowHtml);
        },
        assignModalWindow:function(id,tagId,title,body){
            $.tmpl("modalWindowTemplate", {id:id, title:title, tagId:tagId, bodyPlaceholder:body})
            .attr("id",id)
            .appendTo("#contents_area_base");
        },
        assignPostButton:function(idName, buttonText){
            $.tmpl("postLinkTemplate", {buttonText:buttonText})
            .attr("href","#"+idName)
            .attr("rel","leanModal")
            .appendTo('#post_area');
        },
        assignShowMoreButton:function(idName, buttonText){
            $.tmpl("buttonTemplate", {buttonText:buttonText})
            .attr("id",idName)
            .appendTo("#contents_area_bottom");
        },
        prependEntity:function(entity){
            var newEntity = $.tmpl("containerTemplate", entity);
            $('#contents_area_main').masonry({
                isAnimated:true,
                animationOptions:{duration:400}
            }).prepend(newEntity).masonry('reload');
        },
        appendEntity:function(entity){
            var _self = this;
            var newEntity = $.tmpl("containerTemplate", entity);
            $('#contents_area_main').masonry({
                isAnimated:true,
                animationOptions:{duration:400}
            }).append(newEntity).masonry('reload');
        }
    };

    function Model(){
        this.initialize.apply(this, arguments);
    }
    Model.prototype = {
        initialize:function(arguments) {
            this.method    = arguments.method;
            this.endPoint  = "/jsonrpc/practice/entry.json";
        },
        batchRequest:function(paramsArray){
            var _self = this;
            var data = [];
            $.each(paramsArray, function(i, params){
                data.push(_self._jsonrpc_param(i+1,params));
            });
            return this._ajax(data);
        },
        request:function(params){
            return this._ajax(this._jsonrpc_param(1,params));
        },
        _jsonrpc_param:function(id, params){
            return {
               jsonrpc : '2.0',
               method  : this.method,
               params  : params,
               id      : id
            };
        },
        _ajax:function(data){
            return $.ajax({
                type          : 'POST',
                url           : this.endPoint,
                dataType      : 'json',
                contentType   : 'application/json',
                scriptCharset : 'utf-8',
                data          : JSON.stringify(data)
            }).fail(function(jqXHR, textStatus) {
                console.log( "Request failed: " + textStatus );
            });
        }
    };

    function Entity(){
        this.initialize.apply(this, arguments);
    }
    Entity.prototype = {
        initialize:function(arguments) {
            this.entryId    = arguments.id;
            this.nickName   = arguments.nickname;
            this.createdAt  = arguments.created_at;
            this.tag        = arguments.tag_id;
            this.detailHtml = arguments.body.replace(/\n/g,'<br/>');
        }
    };

    $(document).ready(function(){
        new Background;
    });

})();
