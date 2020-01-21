package com.tvnz;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.databind.JsonMappingException;
import net.bican.wordpress.Post;
import net.bican.wordpress.Wordpress;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.Gson;
import net.bican.wordpress.exceptions.InsufficientRightsException;
import net.bican.wordpress.exceptions.InvalidArgumentsException;
import net.bican.wordpress.exceptions.ObjectNotFoundException;
import redstone.xmlrpc.XmlRpcFault;
import java.io.IOException;
import java.net.MalformedURLException;

public final class App implements RequestHandler<Object, Object> {

    public static String handleRequest(String arg, Context context) {
        return "Handle Request: "+arg;
    }

    public Object handleRequest(Object o, Context context) {
        Item item = new Item();
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            objectMapper.configure(JsonParser.Feature.ALLOW_UNQUOTED_FIELD_NAMES, true);
            Gson gson = new Gson();
            final String inputJson = gson.toJson(o);
            item = objectMapper.readValue(inputJson, Item.class);
            Wordpress wp = new Wordpress(
                    "admin",
                    "admin",
                    "http://" + item.getUrl() + "/xmlrpc.php");
            Post post = new Post();
            post.setPost_title(item.getTitle());
            post.setPost_content(item.getContent());
            post.setPost_status("approved");
            wp.newPost(post);
        } catch (JsonParseException e) {
            e.printStackTrace();
            return "Post process has failed : JSON Parse Exception : " + e.getMessage() + " " + " Title = " + item.getTitle() + " Content = " + item.getContent() + " URL = " + item.getUrl();
        } catch (JsonMappingException e) {
            e.printStackTrace();
            return "Post process has failed : JSON Mapping Exception : " + e.getMessage() + " " + " Title = " + item.getTitle() + " Content = " + item.getContent() + " URL = " + item.getUrl();
        } catch (MalformedURLException e) {
            e.printStackTrace();
            return "Post process has failed : Malformed URL Exception : " + e.getMessage() + " " + " Title = " + item.getTitle() + " Content = " + item.getContent() + " URL = " + item.getUrl();
        } catch (IOException e) {
            e.printStackTrace();
            return "Post process has failed : IO/Network Exception : " + e.getMessage() + " " + " Title = " + item.getTitle() + " Content = " + item.getContent() + " URL = " + item.getUrl();
        } catch (ObjectNotFoundException e) {
            e.printStackTrace();
            return "Post process has failed : Object Not Found Exception : " + e.getMessage() + " " + " Title = " + item.getTitle() + " Content = " + item.getContent() + " URL = " + item.getUrl();
        } catch (XmlRpcFault e) {
            e.printStackTrace();
            return "Post process has failed : RPC Connection Exception : " + e.getMessage() + " " + " Title = " + item.getTitle() + " Content = " + item.getContent() + " URL = " + item.getUrl();
        } catch (InvalidArgumentsException e) {
            e.printStackTrace();
            return "Post process has failed : Input Invalid Exception : " + e.getMessage() + " " + " Title = " + item.getTitle() + " Content = " + item.getContent() + " URL = " + item.getUrl();
        } catch (InsufficientRightsException e) {
            e.printStackTrace();
            return "Post process has failed : Permission Exception : " + e.getMessage() + " " + " Title = " + item.getTitle() + " Content = " + item.getContent() + " URL = " + item.getUrl();
        }
        return "Post processed successfully for : " +item.getTitle()+ " " +item.getContent()+" " +item.getUrl();
    }
}