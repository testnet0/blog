package com.minzheng.blog.controller;


import cn.hutool.captcha.CaptchaUtil;
import cn.hutool.captcha.LineCaptcha;
import com.minzheng.blog.annotation.AccessLimit;
import com.minzheng.blog.dto.UserAreaDTO;
import com.minzheng.blog.dto.UserInfoDTO;
import com.minzheng.blog.service.RedisService;
import com.minzheng.blog.vo.PageResult;
import com.minzheng.blog.dto.UserBackDTO;
import com.minzheng.blog.service.UserAuthService;
import com.minzheng.blog.vo.*;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiOperation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import javax.validation.Valid;
import javax.validation.constraints.NotNull;
import java.io.IOException;
import java.util.List;

import static com.minzheng.blog.constant.RedisPrefixConst.IMAGE_CODE_KEY;

/**
 * 用户账号控制器
 *
 * @author yezhiqiu
 * @date 2021/07/28
 */
@Api(tags = "用户账号模块")
@RestController
public class UserAuthController {
    @Autowired
    private UserAuthService userAuthService;
    @Autowired
    private RedisService redisService;

    /**
     * 发送邮箱验证码
     *
     * @param username 用户名
     * @return {@link Result<>}
     */
    @AccessLimit(seconds = 60, maxCount = 10)
    @ApiOperation(value = "发送邮箱验证码")
    @ApiImplicitParam(name = "username", value = "用户名", required = true, dataType = "String")
    @GetMapping("/users/code")
    public Result<?> sendCode(String username, String captcha, String timestamp) {
        if (!captcha.equalsIgnoreCase((String) redisService.get(IMAGE_CODE_KEY + timestamp))) {
            return Result.fail("图形验证码不正确");
        }
        userAuthService.sendCode(username);
        return Result.ok();
    }

    /**
     * 获取用户区域分布
     *
     * @param conditionVO 条件
     * @return {@link Result<UserAreaDTO>} 用户区域分布
     */
    @ApiOperation(value = "获取用户区域分布")
    @GetMapping("/admin/users/area")
    public Result<List<UserAreaDTO>> listUserAreas(ConditionVO conditionVO) {
        return Result.ok(userAuthService.listUserAreas(conditionVO));
    }

    /**
     * 查询后台用户列表
     *
     * @param condition 条件
     * @return {@link Result<UserBackDTO>} 用户列表
     */
    @ApiOperation(value = "查询后台用户列表")
    @GetMapping("/admin/users")
    public Result<PageResult<UserBackDTO>> listUsers(ConditionVO condition) {
        return Result.ok(userAuthService.listUserBackDTO(condition));
    }

    /**
     * 用户注册
     *
     * @param user 用户信息
     * @return {@link Result<>}
     */
    @ApiOperation(value = "用户注册")
    @PostMapping("/register")
    public Result<?> register(@Valid @RequestBody UserVO user) {
        userAuthService.register(user);
        return Result.ok();
    }

    /**
     * 修改密码
     *
     * @param user 用户信息
     * @return {@link Result<>}
     */
    @ApiOperation(value = "修改密码")
    @PutMapping("/users/password")
    public Result<?> updatePassword(@Valid @RequestBody UserVO user) {
        userAuthService.updatePassword(user);
        return Result.ok();
    }

    /**
     * 修改管理员密码
     *
     * @param passwordVO 密码信息
     * @return {@link Result<>}
     */
    @ApiOperation(value = "修改管理员密码")
    @PutMapping("/admin/users/password")
    public Result<?> updateAdminPassword(@Valid @RequestBody PasswordVO passwordVO) {
        userAuthService.updateAdminPassword(passwordVO);
        return Result.ok();
    }

    /**
     * 微博登录
     *
     * @param weiBoLoginVO 微博登录信息
     * @return {@link Result<UserInfoDTO>} 用户信息
     */
    @ApiOperation(value = "微博登录")
    @PostMapping("/users/oauth/weibo")
    public Result<UserInfoDTO> weiboLogin(@Valid @RequestBody WeiboLoginVO weiBoLoginVO) {
        return Result.ok(userAuthService.weiboLogin(weiBoLoginVO));
    }

    /**
     * qq登录
     *
     * @param qqLoginVO qq登录信息
     * @return {@link Result<UserInfoDTO>} 用户信息
     */
    @ApiOperation(value = "qq登录")
    @PostMapping("/users/oauth/qq")
    public Result<UserInfoDTO> qqLogin(@Valid @RequestBody QQLoginVO qqLoginVO) {
        return Result.ok(userAuthService.qqLogin(qqLoginVO));
    }

    @ApiOperation(value = "获取图形验证码")
    @GetMapping("captcha")
    public void getCaptcha(@Valid @NotNull String timestamp, HttpServletResponse response) throws IOException {

        LineCaptcha lineCaptcha = CaptchaUtil.createLineCaptcha(100, 30, 4, 25);
        //生成文字验证码
        String text = lineCaptcha.getCode();
        // 将验证码存入redis，设置过期时间为5分钟
        redisService.set(IMAGE_CODE_KEY + timestamp, text, 5 * 60);
        lineCaptcha.write(response.getOutputStream());
    }

}

